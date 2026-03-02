defmodule DocmapperPhx.DoctorsTest do
  use DocmapperPhx.DataCase

  alias DocmapperPhx.Doctors

  describe "doctors" do
    alias DocmapperPhx.Doctors.Doctor

    import DocmapperPhx.DoctorsFixtures

    @invalid_attrs %{name: nil, cpso: nil, specialty: nil, gender: nil, primary_location: nil, languages_spoken: nil, phone_number: nil, lat: nil, lon: nil, famdoc: nil}

    test "list_doctors/0 returns all doctors" do
      doctor = doctor_fixture()
      assert Doctors.list_doctors() == [doctor]
    end

    test "get_doctor!/1 returns the doctor with given id" do
      doctor = doctor_fixture()
      assert Doctors.get_doctor!(doctor.id) == doctor
    end

    test "create_doctor/1 with valid data creates a doctor" do
      valid_attrs = %{name: "some name", cpso: 42, specialty: "some specialty", gender: "some gender", primary_location: "some primary_location", languages_spoken: "some languages_spoken", phone_number: "some phone_number", lat: 120.5, lon: 120.5, famdoc: true}

      assert {:ok, %Doctor{} = doctor} = Doctors.create_doctor(valid_attrs)
      assert doctor.name == "some name"
      assert doctor.cpso == 42
      assert doctor.specialty == "some specialty"
      assert doctor.gender == "some gender"
      assert doctor.primary_location == "some primary_location"
      assert doctor.languages_spoken == "some languages_spoken"
      assert doctor.phone_number == "some phone_number"
      assert doctor.lat == 120.5
      assert doctor.lon == 120.5
      assert doctor.famdoc == true
    end

    test "create_doctor/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Doctors.create_doctor(@invalid_attrs)
    end

    test "update_doctor/2 with valid data updates the doctor" do
      doctor = doctor_fixture()
      update_attrs = %{name: "some updated name", cpso: 43, specialty: "some updated specialty", gender: "some updated gender", primary_location: "some updated primary_location", languages_spoken: "some updated languages_spoken", phone_number: "some updated phone_number", lat: 456.7, lon: 456.7, famdoc: false}

      assert {:ok, %Doctor{} = doctor} = Doctors.update_doctor(doctor, update_attrs)
      assert doctor.name == "some updated name"
      assert doctor.cpso == 43
      assert doctor.specialty == "some updated specialty"
      assert doctor.gender == "some updated gender"
      assert doctor.primary_location == "some updated primary_location"
      assert doctor.languages_spoken == "some updated languages_spoken"
      assert doctor.phone_number == "some updated phone_number"
      assert doctor.lat == 456.7
      assert doctor.lon == 456.7
      assert doctor.famdoc == false
    end

    test "update_doctor/2 with invalid data returns error changeset" do
      doctor = doctor_fixture()
      assert {:error, %Ecto.Changeset{}} = Doctors.update_doctor(doctor, @invalid_attrs)
      assert doctor == Doctors.get_doctor!(doctor.id)
    end

    test "delete_doctor/1 deletes the doctor" do
      doctor = doctor_fixture()
      assert {:ok, %Doctor{}} = Doctors.delete_doctor(doctor)
      assert_raise Ecto.NoResultsError, fn -> Doctors.get_doctor!(doctor.id) end
    end

    test "change_doctor/1 returns a doctor changeset" do
      doctor = doctor_fixture()
      assert %Ecto.Changeset{} = Doctors.change_doctor(doctor)
    end
  end
end
