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
end
