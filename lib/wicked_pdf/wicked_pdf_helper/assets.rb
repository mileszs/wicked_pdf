require 'open-uri'

class WickedPdf
  module WickedPdfHelper
    module Assets
      ASSET_URL_REGEX = /url\(['"]?([^'"]+?)['"]?\)/

      def wicked_pdf_asset_base64(path)
        asset = find_asset(path)
        raise "Could not find asset '#{path}'" if asset.nil?
        base64 = Base64.encode64(asset.to_s).gsub(/\s+/, '')
        "data:#{asset.content_type};base64,#{Rack::Utils.escape(base64)}"
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

        if Webpacker.dev_server.running?
          stylesheet_pack_tag(*sources)
        else
          css_text = sources.collect do |source|
            source = WickedPdfHelper.add_extension(source, 'css')
            source_path = asset_pack_path(source)
            wicked_pdf_stylesheet_link_tag(root_url[0...-1] + source_path)
          end.join("\n")
          css_text.respond_to?(:html_safe) ? css_text.html_safe : css_text
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
        encoding = ':UTF-8' if RUBY_VERSION > '1.8'
        asset = open(uri, "r#{encoding}", &:read)
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
    end
  end
end
