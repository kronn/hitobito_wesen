# frozen_string_literal: true

#  Copyright (c) 2012-2026, Wesentliche Wesen. This file is part of
#  hitobito_wesen and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/kronn/hitobito_wesen.


namespace :app do
  namespace :license do
    task :config do # rubocop:disable Rails/RakeEnvironment
      @licenser = Licenser.new("hitobito_wesen",
                               "Puzzle ITC",
                               "https://github.com/kronn/hitobito_wesen")
    end
  end
end
