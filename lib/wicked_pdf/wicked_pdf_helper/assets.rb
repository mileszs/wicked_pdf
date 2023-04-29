require 'net/http'
require 'delegate'
require 'stringio'

class WickedPdf
  module WickedPdfHelper
    module Assets
      ASSET_URL_REGEX = /url\(['"]?([^'"]+?)['"]?\)/

      class PropshaftAsset < SimpleDelegator
        def content_type
          super.to_s
        end

        def to_s
          content
        end

        def filename
          path.to_s
        end
      end

      def wicked_pdf_asset_base64(path)
        asset = find_asset(path)
        raise "Could not find asset '#{path}'" if asset.nil?

        base64 = Base64.encode64(asset.to_s).gsub(/\s+/, '')
        "data:#{asset.content_type};base64,#{Rack::Utils.escape(base64)}"
      end

      # Using `image_tag` with URLs when generating PDFs (specifically large PDFs with lots of pages) can cause buffer/stack overflows.
      #
      def wicked_pdf_url_base64(url)
        response = Net::HTTP.get_response(URI(url))

        if response.is_a?(Net::HTTPSuccess)
          base64 = Base64.encode64(response.body).gsub(/\s+/, '')
          "data:#{response.content_type};base64,#{Rack::Utils.escape(base64)}"
        else
          Rails.logger.warn("[wicked_pdf] #{response.code} #{response.message}: #{url}")
          nil
        end
      end

      def wicked_pdf_stylesheet_link_tag(*sources)
        stylesheet_contents = sources.collect do |source|
          source = WickedPdfHelper.add_extension(source, 'css')
          "<style type='text/css'>#{read_asset(source)}</style>"
        end.join("\n")

        stylesheet_contents.gsub(ASSET_URL_REGEX) do
          if Regexp.last_match[1].starts_with?('data:')
            "url(#{Regexp.last_match[1]})"
          else
            "url(#{wicked_pdf_asset_path(Regexp.last_match[1])})"
          end
        end.html_safe
      end

      def wicked_pdf_stylesheet_pack_tag(*sources)
        return unless defined?(Webpacker)

        if running_in_development?
          stylesheet_pack_tag(*sources)
        else
          css_text = sources.collect do |source|
            source = WickedPdfHelper.add_extension(source, 'css')
            wicked_pdf_stylesheet_link_tag(webpacker_source_url(source))
          end.join("\n")
          css_text.respond_to?(:html_safe) ? css_text.html_safe : css_text
        end
      end

      def wicked_pdf_javascript_pack_tag(*sources)
        return unless defined?(Webpacker)

        if running_in_development?
          javascript_pack_tag(*sources)
        else
          sources.collect do |source|
            source = WickedPdfHelper.add_extension(source, 'js')
            "<script type='text/javascript'>#{read_asset(webpacker_source_url(source))}</script>"
          end.join("\n").html_safe
        end
      end

      def wicked_pdf_image_tag(img, options = {})
        image_tag wicked_pdf_asset_path(img), options
      end

      def wicked_pdf_javascript_src_tag(jsfile, options = {})
        jsfile = WickedPdfHelper.add_extension(jsfile, 'js')
        javascript_include_tag wicked_pdf_asset_path(jsfile), options
      end

      def wicked_pdf_javascript_include_tag(*sources)
        sources.collect do |source|
          source = WickedPdfHelper.add_extension(source, 'js')
          "<script type='text/javascript'>#{read_asset(source)}</script>"
        end.join("\n").html_safe
      end

      def wicked_pdf_asset_path(asset)
        if (pathname = asset_pathname(asset).to_s) =~ URI_REGEXP
          pathname
        else
          "file:///#{pathname}"
        end
      end

      def wicked_pdf_asset_pack_path(asset)
        return unless defined?(Webpacker)

        if running_in_development?
          asset_pack_path(asset)
        else
          wicked_pdf_asset_path webpacker_source_url(asset)
        end
      end

      private

      # borrowed from actionpack/lib/action_view/helpers/asset_url_helper.rb
      URI_REGEXP = %r{^[-a-z]+://|^(?:cid|data):|^//}

      def asset_pathname(source)
        if precompiled_or_absolute_asset?(source)
          asset = asset_path(source)
          pathname = prepend_protocol(asset)
          if pathname =~ URI_REGEXP
            # asset_path returns an absolute URL using asset_host if asset_host is set
            pathname
          else
            File.join(Rails.public_path, asset.sub(/\A#{Rails.application.config.action_controller.relative_url_root}/, ''))
          end
        else
          asset = find_asset(source)
          if asset
            # older versions need pathname, Sprockets 4 supports only filename
            asset.respond_to?(:filename) ? asset.filename : asset.pathname
          else
            File.join(Rails.public_path, source)
          end
        end
      end

      def find_asset(path)
        if Rails.application.assets.respond_to?(:find_asset)
          Rails.application.assets.find_asset(path, :base_path => Rails.application.root.to_s)
        elsif defined?(Propshaft::Assembly) && Rails.application.assets.is_a?(Propshaft::Assembly)
          PropshaftAsset.new(Rails.application.assets.load_path.find(path))
        else
          Sprockets::Railtie.build_environment(Rails.application).find_asset(path, :base_path => Rails.application.root.to_s)
        end
      end

      # will prepend a http or default_protocol to a protocol relative URL
      # or when no protcol is set.
      def prepend_protocol(source)
        protocol = WickedPdf.config[:default_protocol] || 'http'
        if source[0, 2] == '//'
          source = [protocol, ':', source].join
        elsif source[0] != '/' && !source[0, 8].include?('://')
          source = [protocol, '://', source].join
        end
        source
      end

      def precompiled_or_absolute_asset?(source)
        !Rails.configuration.respond_to?(:assets) ||
          Rails.configuration.assets.compile == false ||
          source.to_s[0] == '/' ||
          source.to_s.match(/\Ahttps?\:\/\//)
      end

      def read_asset(source)
        if precompiled_or_absolute_asset?(source)
          pathname = asset_pathname(source)
          if pathname =~ URI_REGEXP
            read_from_uri(pathname)
          elsif File.file?(pathname)
            IO.read(pathname)
          end
        else
          find_asset(source).to_s
        end
      end

      def read_from_uri(uri)
        asset = Net::HTTP.get(URI(uri))
        asset.force_encoding('UTF-8') if asset
        asset = gzip(asset) if WickedPdf.config[:expect_gzipped_remote_assets]
        asset
      end

      def gzip(asset)
        stringified_asset = StringIO.new(asset)
        gzipper = Zlib::GzipReader.new(stringified_asset)
        gzipper.read
      rescue Zlib::GzipFile::Error
        nil
      end

      def webpacker_source_url(source)
        return unless webpacker_version

        # In Webpacker 3.2.0 asset_pack_url is introduced
        if webpacker_version >= '3.2.0'
          if (host = Rails.application.config.asset_host)
            asset_pack_path(source, :host => host)
          else
            asset_pack_url(source)
          end
        else
          source_path = asset_pack_path(source)
          # Remove last slash from root path
          root_url[0...-1] + source_path
        end
      end

      def running_in_development?
        return unless webpacker_version

        # :dev_server method was added in webpacker 3.0.0
        if Webpacker.respond_to?(:dev_server)
          Webpacker.dev_server.running?
        else
          Rails.env.development? || Rails.env.test?
        end
      end

      def webpacker_version
        return unless defined?(Webpacker)

        # If webpacker is used, need to check for version
        require 'webpacker/version'

        Webpacker::VERSION
      end
    end
  end
end
