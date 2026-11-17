# frozen_string_literal: true

#  Copyright (c) 2012-2026, Puzzle ITC. This file is part of
#  hitobito_wesen and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/kronn/hitobito_wesen.


class Group::Wesen < ::Group
  self.layer = true
  children Group::WesenGruppe

  ### ROLES

  class Administration < ::Role
    self.permissions = [:admin, :layer_and_below_full, :impersonation]
    self.two_factor_authentication_enforced = true
  end


  class Vorstand < ::Role
    self.permissions = [:group_full, :finance]
  end


  class Organisation < ::Role
    self.permissions = [:group_full]
  end


  class Wesen < ::Role
    self.permissions = [:group_read]
  end


  class Neuwesen < ::Role
  end


  roles Administration, Vorstand, Organisation, Wesen, Neuwesen
end
