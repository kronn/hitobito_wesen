# frozen_string_literal: true

namespace :app do
  namespace :license do
    task :config do # rubocop:disable Rails/RakeEnvironment
      @licenser = Licenser.new("hitobito_wesen",
                               "Wesentliche Wesen",
                               "https://github.com/kronn/hitobito_wesen")
    end
  end
end
