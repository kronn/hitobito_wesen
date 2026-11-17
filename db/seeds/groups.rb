# frozen_string_literal: true

#  Copyright (c) 2012-2026, Puzzle ITC. This file is part of
#  hitobito_wesen and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/kronn/hitobito_wesen.


Group::Wesen.seed_once(:parent_id, name: "Alle Wesen")

root = Group.roots.first

Group::WesenGruppe.seed_once(:name, parent_id: root.id, name: "FINTA")
Group::WesenGruppe.seed_once(:name, parent_id: root.id, name: "Regional Bern", short_name: "Bern")
Group::WesenGruppe.seed_once(:name, parent_id: root.id, name: "Regional Zürich", short_name: "Zürich")
