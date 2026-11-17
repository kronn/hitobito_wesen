# frozen_string_literal: true

#  Copyright (c) 2026-2026, Puzzle ITC. This file is part of
#  hitobito_wesen and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_wesen.

class Group::WesenGruppe < ::Group
  ### ROLES

  class Organisation < ::Role
    self.permissions = [:group_full]
  end


  class Wesen < ::Role
    self.permissions = [:group_read]
  end


  class Neuwesen < ::Role
  end


  roles Organisation, Wesen, Neuwesen
end
