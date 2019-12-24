class WickedPdf
  module WickedPdfHelper
    module Assets
      AssetWrapper = Struct.new(:asset, :filename) do
        def source
          asset.respond_to?(:source) ? source.source : asset
        end

        def to_s
          asset.to_s
        end

        def content_type
          asset.respond_to?(:content_type) ? source.content_type : get_mime_type
        end

        def extension
          filename.to_s[/^.*\/?.*?\.(\w+)(\?.*)?/, 1]
        end

        private

        def get_mime_type
          mime = Mime::Type.lookup_by_extension(extension)

          raise 'Mime not Found' unless mime

          mime
        rescue StandardError
          `file --b --mime-type '#{filename}'`.strip
        end
      end
    end
  end
end
