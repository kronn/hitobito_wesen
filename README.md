# Hitobito Wesen

This hitobito wagon defines the organization hierarchy with groups and roles
of Wesen.


## Wesen Organization Hierarchy

<!-- roles:start -->
    * Wesen
      * Wesen
        * Administration: 2FA [:admin, :layer_and_below_full, :impersonation]
        * Vorstand: [:group_full, :finance]
        * Organisation: [:group_full]
        * Wesen: [:group_read]
        * Neuwesen: []
      * WesenGruppe
        * Organisation: [:group_full]
        * Wesen: [:group_read]
        * Neuwesen: []

(Output of rake app:hitobito:roles)
<!-- roles:end -->