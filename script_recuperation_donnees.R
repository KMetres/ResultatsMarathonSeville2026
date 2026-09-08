### 1. Packages nécessaire ----

library(httr2)
library(tidyverse)
library(readODS)

### 2. URL de l'API ----

  # Lien de la page 

# https://www.zurichmaratonsevilla.es/en/zms-results-2026

  # URL de l'API à interroger

url = "https://rankings-storage.timingsense.cloud/prod/competitions/69673d3e-658c-41f2-bc48-13d4ac1f19fc/Marat%C3%B3n/participants.json"

### 3. Récupération du JSON contenant les données des participants ----

resp = request(url) |>
  req_perform()

participants = resp |>
  resp_body_json()

  # Vérification nombre de participants

length(participants) # 17.222 → ok

### 4. Structure des données des participants ----

  # Regards des informations sur quelques participants

participants[[1]]

names(participants[[1]])

participants[[1]]$dorsal
participants[[1]]$fullName
participants[[1]]$nationality
participants[[1]]$status

  # → non partie

participants[[2]]$dorsal
participants[[2]]$fullName
participants[[2]]$nationality
participants[[2]]$status

participants[[2]]$times$Meta
participants[[2]]$rankings$Meta

  # → Finisher


### 5. Test de récupération des données en tableau ----

test1 = tibble(participant = participants[1:10]) |>
  unnest_wider(participant)

names(test1)

# test2 = tibble(participant = participants[1:10]) |>
#   unnest_wider(participant) |> select(id,name,surname,fullName,gender,nationality,status,times, rankings) |>
#   unnest_wider(c(times, rankings), names_sep = "_") |>
#   unnest_wider(c(rankings_Meta,times_Meta), , names_sep = "_")

test2 = tibble(participant = participants[1:10]) |>
  unnest_wider(participant) |> 
  select(id,name,surname,fullName,gender,nationality,status,times, rankings) |>
  mutate(id = as.character(id)) |>
  unnest_wider(c(id,times), names_sep = "_") |> unnest_wider(times_Meta, names_sep = "_") |>
  select("id" = id_1,name,surname,fullName,gender,nationality,status,times_Meta_netTime) |>
  mutate(
    temps_net = sprintf(
      "%02d:%02d:%02d",
      times_Meta_netTime %/% 3600000,
      (times_Meta_netTime %% 3600000) %/% 60000,
      (times_Meta_netTime %% 60000) %/% 1000
    ) # Passage de millisecondes en heures/minutes/secondes
  )

names(test2)


### 6. Récupération de l'ensemble des données ----

don.ens = tibble(participant = participants) |>
  unnest_wider(participant) |> 
  select(id,name,surname,fullName,gender,nationality,status,times, rankings) |>
  mutate(id = as.character(id)) |>
  unnest_wider(c(id,times), names_sep = "_") |> unnest_wider(times_Meta, names_sep = "_") |>
  select("id" = id_1,name,surname,fullName,gender,nationality,status,times_Meta_netTime) |>
  mutate(
    temps_net = sprintf(
      "%02d:%02d:%02d",
      times_Meta_netTime %/% 3600000,
      (times_Meta_netTime %% 3600000) %/% 60000,
      (times_Meta_netTime %% 60000) %/% 1000
    ) # Passage de millisecondes en heures/minutes/secondes
  )

nrow(don.ens)

  # Restriction aux français

don.fr = don.ens |> filter(nationality == "FRA") |> arrange(times_Meta_netTime)


### 7. Export des résultats des français ----

write_ods(don.fr, "resultats_des_francais.ods")


