# frozen_string_literal: true

namespace :app do
  namespace :license do
    task :config do # rubocop:disable Rails/RakeEnvironment
      @licenser = Licenser.new("hitobito_wesen",
                               "TODO: Customer Name",
                               "https://github.com/hitobito/hitobito_wesen")
    end
  end
end
