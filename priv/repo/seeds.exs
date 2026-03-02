# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     DocmapperPhx.Repo.insert!(%DocmapperPhx.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
 %{name: "test", cpso: 123, specialty: "test", gender: "Female", primary_location: "abc", languages_spoken: "English", phone_number: "123", lat: 45.5, lon: -75} |> DocmapperPhx.Doctors.create_doctor()
