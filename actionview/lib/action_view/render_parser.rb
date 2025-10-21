# frozen_string_literal: true

begin
  require "prism"
rescue LoadError
  # If Prism isn't available (because of using an older Ruby version) then we'll
  # define a fallback parser using ripper.
end

module ActionView
  module RenderParser # :nodoc:
    ALL_KNOWN_KEYS = [:partial, :template, :layout, :formats, :locals, :object, :collection, :as, :status, :content_type, :location, :spacer_template]
    RENDER_TYPE_KEYS = [:partial, :template, :layout]

    class Base # :nodoc:
      def initialize(name, code)
        @name = name
        @code = code
      end

      private
        def directory
          File.dirname(@name)
        end

        def partial_to_virtual_path(render_type, partial_path)
          if render_type == :partial || render_type == :layout
            partial_path.gsub(%r{(/|^)([^/]*)\z}, '\1_\2')
          else
            partial_path
          end
        end
    end

    # Prism is the default since Ruby 3.4. Otherwise, use ripper.
    if defined?(Prism) && RUBY_VERSION >= "3.4.0"
      require_relative "render_parser/prism_render_parser"
      Default = PrismRenderParser
    else
      require "ripper"
      require_relative "render_parser/ripper_render_parser"
      Default = RipperRenderParser
    end
  end
end
