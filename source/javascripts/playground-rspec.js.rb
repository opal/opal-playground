require 'opal'
require 'opal-parser'

require '_vendor/jquery'
require '_vendor/bootstrap'
require 'opal-jquery'

require '_vendor/codemirror'
require '_vendor/codemirror-ruby'

require '_playground/editor'

module Playground
  class RSpecRunner
    def initialize
      @ruby = Editor.new(:ruby_pane, mode: 'ruby', lineNumbers: true,
                         theme: 'solarized light', extraKeys: {
                          'Cmd-Enter' => proc { run_code }
                        })

      @result = Element['#result-frame']

      Element.find('#run-code').on(:click) { run_code }
      @link = Element.find('#link-code')

      hash = `decodeURIComponent(location.hash)`

      if hash.start_with? '#code:'
        @ruby.value = hash[6..-1]
      else
        @ruby.value = RUBY.strip
      end

      run_code
    end

    def run_code
      @link[:href] = "#code:#{`encodeURIComponent(#{@ruby.value})`}"
      js = Opal.compile @ruby.value

      update_iframe(<<-HTML)
        <html>
          <head>
          </head>
          <body>
            <script src="../javascripts/rspec_results.js"></script>
            <script>
              #{js}
            </script>
            <script>
              Opal.Opal.RSpec.Runner.$autorun();
            </script>
            <style>
              #label { display: none; }
              #display-filters { display: none; }
            </style>
          </body>
        </html>
      HTML
    rescue => e
      alert "#{e.class}: #{e.message}"
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

    RUBY = <<-EOF
User = Struct.new(:name) do
  def admin?
    name == 'Ford Prefect'
  end
end

describe 'User' do
  it "should initialize with the given name" do
    expect(User.new('Adam').name).to eq('Adam')
  end

  it "should be an admin only if user is Ford Prefect" do
    expect(User.new('Adam')).to_not be_admin
    expect(User.new('Ford Prefect')).to be_admin
  end

  it "compares admin? using ==" do
    name = double("name")
    expect(name).to receive(:==).once.and_return(true)
    user = User.new(name)
    # uncomment this line and re-running
    # user.admin?
  end
end
    EOF
  end
end

Document.ready? do
  Playground::RSpecRunner.new
end
