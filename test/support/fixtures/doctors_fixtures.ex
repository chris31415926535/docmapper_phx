defmodule DocmapperPhx.DoctorsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `DocmapperPhx.Doctors` context.
  """

  @doc """
  Generate a doctor.
  """
  def doctor_fixture(attrs \\ %{}) do
    {:ok, doctor} =
      attrs
      |> Enum.into(%{
        cpso: 42,
        famdoc: true,
        gender: "some gender",
        languages_spoken: "some languages_spoken",
        lat: 120.5,
        lon: 120.5,
        name: "some name",
        phone_number: "some phone_number",
        primary_location: "some primary_location",
        specialty: "some specialty"
      })
      |> DocmapperPhx.Doctors.create_doctor()

    doctor
  end
end
