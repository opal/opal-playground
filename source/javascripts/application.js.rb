require 'opal'
require 'opal-parser'

require '_vendor/jquery'
require '_vendor/bootstrap'
require 'opal-jquery'

require '_vendor/codemirror'
require '_vendor/codemirror-html'
require '_vendor/codemirror-css'
require '_vendor/codemirror-ruby'

module Playground
  class Editor
    OPTIONS = { lineNumbers: true, theme: 'solarized light' }

    def initialize(dom_id, options)
      options = OPTIONS.merge(options).to_n
      @native = `CodeMirror(document.getElementById(dom_id), #{options})`
    end

    def value=(str)
      `#@native.setValue(str)`
    end

    def value
      `#@native.getValue()`
    end
  end

  class Runner
    def initialize
      @html = create_editor(:html_pane, mode: 'xml')
      @ruby = create_editor(:ruby_pane, mode: 'ruby')
      @css  = create_editor(:css_pane, mode: 'css')
      @result = Element['#result-frame']

      @html.value = HTML
      @ruby.value = RUBY
      @css.value = CSS

      Element.find('#run-code').on(:click) { run_code }

      run_code
    end

    def create_editor(id, opts)
      opts = { lineNumbers: true,
               theme: 'solarized light',
               extraKeys: {
                 'Cmd-Enter' => proc { run_code }
               }
      }.merge(opts)

      Editor.new(id, opts)
    end

    def run_code
      html, css, ruby = @html.value, @css.value, @ruby.value
      javascript = Opal.compile ruby

      update_iframe(<<-HTML)
        <html>
          <head>
            <style>#{css}</style>
          </head>
          <body>
            #{html}
            <script src="javascripts/result_boot.js"></script>
            <script>
              #{javascript}
            </script>
          </body>
        </html>
      HTML
    end

    def update_iframe(html)
      %x{
        var iframe = #@result[0], doc;

        if (iframe.contentDocument) {
          doc = iframe.contentDocument;
        } else if (iframe.contentWindow) {
          doc = iframe.contentWindow.document;
        } else {
          doc = iframe.document;
        }

        doc.open()
        doc.writeln(#{html});
        doc.close();
      }
    end
  end

  HTML = <<-HTML
<button id="main">
  Click me
</button>
  HTML

  CSS = <<-CSS
body {
  background: #eeeeee;
}
  CSS

  RUBY = <<-RUBY
Document.ready? do
  Element.find('#main').on(:click) do
    alert "Hello, World!"
  end
end
  RUBY
end

Document.ready? do
  Playground::Runner.new
end
