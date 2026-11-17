# hitobito "Wesen" mit docker compose betreiben

`docker-compose.yaml` startet ein produktionsnahes hitobito mit diesem Wagon:

| Service    | Zweck                                                             |
|------------|-------------------------------------------------------------------|
| `rails`    | Puma auf Port 3000, liefert die vorkompilierten Assets selbst aus |
| `worker`   | Delayed::Job-Worker / Background-Jobs                             |
| `postgres` | Datenbank, enthält auch die Delayed::Job-Queue                    |
| `migrate`  | Führt Migrationen und Seeds einmalig aus und beendet sich         |
| `redis`    | Rails-Cache und ActionCable                                       |

`rails` und `worker` starten erst, wenn `migrate` erfolgreich beendet wurde.

## Einrichtung

1. Ein Verzeichnis anlegen, das nur den Core, diesen Wagon und das Compose-File enthält:

   ```
   hitobito-application/
   ├── docker-compose.yaml   # aus diesem Verzeichnis kopiert
   ├── .dockerignore         # Kopie von dockerignore aus diesem Verzeichnis
   ├── .env
   ├── mail.yml              # Mailempfang, siehe Schritt 3
   ├── hitobito/             # https://github.com/hitobito/hitobito
   └── hitobito_wesen/       # https://github.com/kronn/hitobito_wesen
   ```

   Der Image-Build übernimmt jedes dort vorhandene `hitobito_*`-Verzeichnis.
   Deshalb braucht jede Kombination von Core und Wagons ein eigenes
   "Composition-Verzeichnis".

   Das Verzeichnis ist der Build-Kontext, und der Build kopiert ihn vollständig
   ins Image. Ein `.dockerignore` ignoriert dabei `.env`, `mail.yml` und lokale
   Dateien der Checkouts (z.B. `config/settings.local.yml`) aus dem Image
   heraus:

   ```sh
   cp hitobito_wesen/doc/dockerignore .dockerignore
   ```

   Die `.dockerignore` im Core greift hier nicht, weil Docker ~docker-Dinge tut~
   diese nur im Root des Build-Kontexts liest.

2. `.env` aus der Vorlage anlegen und ausfüllen:

   ```sh
   cp hitobito_wesen/doc/.env.example .env
   ```

   `SECRET_KEY_BASE`, `POSTGRES_PASSWORD` und `RAILS_HOST_NAME` sind notwendig.
   Die anderen Variablen sind in `doc/operator/01_deployment.md` im Core beschrieben.

3. `mail.yml` für den Empfang der Mailinglisten anlegen (Catch-All-Postfach per IMAP),
   Vorlage ist `hitobito/config/mail.yml.example`:

   ```yaml
   imap:
     interval: 1                 # Minuten zwischen zwei Abrufen, 0 deaktiviert den Abruf
     address: imap.example.org
     user_name: catch-all@example.org
     password: UGFzc3dvcnQ0Mj8=      # base64: echo -n 'Passwort42?' | base64
     enable_ssl: true
     imap_port: 993
   ```

   Die Datei wird zur Laufzeit nach `config/mail.yml` gemountet und nicht ins
   Image gebaut. Sie muss für den Container-User (uid 1001) lesbar sein:
   `chmod 644 mail.yml`.

   Ohne Mailinglisten die beiden `secrets:`-Blöcke aus `docker-compose.yaml`
   entfernen.

4. Bauen und starten:

   ```sh
   docker compose up --build
   ```

   Der erste Build dauert 10 bis 15 Minuten, da hier auch alle Dependencies
   geholt werden müssen.

5. `http://localhost:3000` öffnen, über "Passwort vergessen" mit
   `RAILS_ROOT_USER_EMAIL` eine Mail anfordern und darüber das Root-Passwort setzen.

## Betrieb

- Update:
  - beide Checkouts aktualisieren (`git pull` oder `git checkout 2.11.0` oder ...)
  - `docker compose up --build -d`
  - `migrate` läuft erneut automatisch, bevor die Applikation neu startet.
- Nach Änderungen an `mail.yml`: `docker compose up -d --force-recreate`.
  `migrate` plant dabei die Mail-Jobs neu ein, `rails` und `worker` lesen die Datei neu.
- Logs: `docker compose logs -f rails worker`
- Konsole: `docker compose exec rails bundle exec rails console`
- Die Daten liegen in den Volumes `pg_data`, `redis_data` und `uploads`.
  `docker compose down -v` löscht sie.

## SSL/TLS mit einem Reverse Proxy

Wenn ein Proxy TLS terminiert, `RAILS_HOST_SSL=true` setzen und den
`ports:`-Eintrag von `rails` entfernen. `/healthz` ist von der HTTPS-Weiterleitung
ausgenommen.

Damit kann man dann auch einen besseren Hostname verbinden, der dann wieder in
`RAILS_HOST_NAME` gesetzt werden muss.

## Einschränkungen

- Das Image lädt eine x86_64-jemalloc-Bibliothek vor und startet nicht auf arm64.
- Ist `mail.yml` nicht gemountet, wird der veraltete Mailempfang über
  `RAILS_MAIL_RETRIEVER_CONFIG` verwendet.

## Alternativen zu docker-compose

- Es ist auch möglich, nur mit `docker buildx build ...` das Image zu erzeugen
  und dorthin zu schieben, wo man es braucht. Ob da dann docker-compose mit einer
  fancy UI läuft oder irgendwas anderes, ist erstmal egal.

- Wenn man das ganze z.B. auf einem Synology NAS laufen lassen will, kann man das
  docker-compose da auch direkt einrichten und das Image zu dem docker-host
  pushen. Der Reverse Proxy ist dann ebenfalls über die Systemeinstellungen
  vorhanden. Aber das sind alles Details, die man auch via Google herausfinden
  kann und auch sollte.

- Wenn man zufällig ein komplettes Kubernetes zur Verfügung hat, hat man vermutlich
  auch einen Ansprechpartner, der einem die Übersetzung von dem docker-compose zu
  kubernetes-YAML machen kann.

## Betrieb ohne Mail

Für einen ersten Start ohne Mailserver:

1. Die beiden `secrets:`-Blöcke aus `docker-compose.yaml` entfernen und keine
   `mail.yml` anlegen. Ohne Postfach-Konfiguration ruft hitobito keine Mails ab.
2. In `.env` `RAILS_MAIL_DELIVERY_METHOD=file` setzen und
   `RAILS_MAIL_DELIVERY_CONFIG` entfernen. Mails werden dann als Dateien unter
   `tmp/mails/` im sendenden Container abgelegt statt verschickt:

   ```sh
   docker compose exec rails ls tmp/mails    # direkt versendete Mails
   docker compose exec worker ls tmp/mails   # im Hintergrund versendete Mails
   ```

   Die Dateien gehen beim Neuerstellen der Container verloren. Mit `smtp` ohne
   erreichbaren Server schlägt jeder Versand mit einem Fehler fehl.
3. Das Root-Passwort direkt setzen, statt über "Passwort vergessen":

   ```sh
   docker compose exec rails bundle exec rails runner \
     'Person.root.update!(password: "ein-langes-passwort", password_confirmation: "ein-langes-passwort")'
   ```

Mailinglisten funktionieren dann natürlich nicht. E-Mail-Adressen werden
weiterhin per DNS (MX-Eintrag) geprüft, dafür braucht der Container
ausgehendes DNS.
