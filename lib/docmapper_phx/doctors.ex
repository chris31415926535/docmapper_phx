defmodule DocmapperPhx.Doctors do
  @moduledoc """
  The Doctors context.
  """

  import Ecto.Query, warn: false
  alias DocmapperPhx.Repo

  alias DocmapperPhx.Doctors.Doctor

  @doc """
  Returns the list of doctors.

  ## Examples

      iex> list_doctors()
      [%Doctor{}, ...]

  """
  def list_doctors do
    Repo.all(Doctor)
  end

  def search_doctors(params) do
    query = from(d in Doctor)

    query =
      query
      |> filter_gender(params)
      |> filter_doctype(params)
      |> filter_language(params)
      |> filter_geo(params)
    # |> limit(10)

    Repo.all(query)
    |> IO.inspect(label: "new docs")
  end

  def filter_gender(query, %{"gender" => gender})
      when gender in ["Male", "Female", "Non-Binary"] do
    query
    |> where([d], d.gender == ^gender)
  end

  def filter_gender(query, _params), do: query

  def filter_doctype(query, %{"doctype" => "a Family Physician"}) do
    query
    |> where([d], d.famdoc == true)
  end

  def filter_doctype(query, %{"doctype" => "Any Physician"}) do
    query
  end

  # use a partial lower-case match for docs with many specialties
  def filter_doctype(query, %{"doctype" => specialty}) do
    search_string = "%#{specialty}%"

    query
    |> where([d], ilike(d.specialty, ^search_string))
  end

  def filter_doctype(query, params) do
    IO.inspect(params, label: "*** filter_doctype failed with these params")
    query
  end

  def filter_language(query, %{"language" => language}) do
    search_string = "%#{language}%"

    query
    |> where([d], ilike(d.languages_spoken, ^search_string))
  end

  def filter_language(query, params) do
    IO.inspect(params, label: "*** filter_language failed with these params")
    query
  end


  ### FILTER FOR GEOGRAPHY
  def filter_geo(
        query,
        %{"neLon" => neLon, "neLat" => neLat, "swLon" => swLon, "swLat" => swLat} = _params
      ) do
    latMin = swLat
    latMax = neLat
    lonMin = swLon
    lonMax = neLon

    query
    |> where(
      [d],
      d.lat > ^latMin and
        d.lat < ^latMax and
        d.lon > ^lonMin and
        d.lon < ^lonMax
    )
  end

  # def filter_geo(query, _params), do: query



  
  @doc """
  Gets a single doctor.

  Raises `Ecto.NoResultsError` if the Doctor does not exist.

  ## Examples

      iex> get_doctor!(123)
      %Doctor{}

      iex> get_doctor!(456)
      ** (Ecto.NoResultsError)

  """
  def get_doctor!(cpso), do: Repo.get!(Doctor, cpso)

  @doc """
  Creates a doctor.

  ## Examples

      iex> create_doctor(%{field: value})
      {:ok, %Doctor{}}

      iex> create_doctor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_doctor(attrs) do
    %Doctor{}
    |> Doctor.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a doctor.

  ## Examples

      iex> update_doctor(doctor, %{field: new_value})
      {:ok, %Doctor{}}

      iex> update_doctor(doctor, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_doctor(%Doctor{} = doctor, attrs) do
    doctor
    |> Doctor.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a doctor.

  ## Examples

      iex> delete_doctor(doctor)
      {:ok, %Doctor{}}

      iex> delete_doctor(doctor)
      {:error, %Ecto.Changeset{}}

  """
  def delete_doctor(%Doctor{} = doctor) do
    Repo.delete(doctor)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking doctor changes.

  ## Examples

      iex> change_doctor(doctor)
      %Ecto.Changeset{data: %Doctor{}}

  """
  def change_doctor(%Doctor{} = doctor, attrs \\ %{}) do
    Doctor.changeset(doctor, attrs)
  end
end
