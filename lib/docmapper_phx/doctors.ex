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
      |> limit(100)

    Repo.all(query)
  end

  def filter_gender(query, %{"gender" => gender})
      when gender in ["Male", "Female", "Non-Binary"] do
    query
    |> where([d], d.gender == ^gender)
  end

  def filter_gender(query, _params), do: query

  def filter_doctype(query, %{"doctype" => "family"}) do
    query
    |> where([d], d.famdoc == true)
  end

  def filter_doctype(query, %{"doctype" => "any"}) do
    query
  end

  # use a partial lower-case match for docs with many specialties
  def filter_doctype(query, %{"doctype" => specialty}) do
    search_string = "%#{specialty}%"

    query
    |> where([d], ilike(d.specialty, ^search_string))
  end

  def filter_doctype(query, _params) do
    query
  end

  def filter_language(query, %{"language" => language}) do
    search_string = "%#{language}%"

    query
    |> where([d], ilike(d.languages_spoken, ^search_string))
  end

  def filter_language(query, _params) do
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

  def filter_geo(query, _params), do: query

  ############## CALCULATE STATITSICS
  #
  def language_stats(params) do
    total_docs_n = Repo.aggregate(Doctor, :count, :cpso)

    total_famdocs_n =
      from(d in Doctor)
      |> where([d], d.famdoc == true)
      |> Repo.aggregate(:count, :cpso)

    query =
      from(d in Doctor)
      |> filter_language(params)

    docs = Repo.all(query)

    total_n = length(docs)
    total_pct = :io_lib.format("~.1f%", [100 * total_n / total_docs_n])
    man_n = Enum.filter(docs, fn doc -> doc.gender == "Male" end) |> length()
    man_pct = man_n / total_n
    woman_n = Enum.filter(docs, fn doc -> doc.gender == "Female" end) |> length()
    woman_pct = woman_n / total_n
    famdoc_n = Enum.filter(docs, fn doc -> doc.famdoc == true end) |> length()
    famdoc_pct = :io_lib.format("~.1f%", [100 * famdoc_n / total_n]) |> to_string()

    famdocs_speak_pct = :io_lib.format("~.1f%", [100 * famdoc_n / total_famdocs_n])

    # do not convert to map, we don't know what the specialties will be
    specialties_n =
      docs
      |> Enum.map(& &1.specialty)
      |> Enum.map(&String.split(&1, ", "))
      |> List.flatten()
      |> Enum.frequencies()
      |> Enum.sort_by(fn {_k, v} -> v end, :desc)
      |> Enum.take(5)

    # convert to a map because we want to match specific keys for LHIN regions
    lhins_n =
      docs
      |> Enum.map(& &1.lhin)
      |> Enum.map(&String.split(&1, ", "))
      |> List.flatten()
      |> Enum.frequencies()
      |> Enum.sort_by(fn {_k, v} -> v end, :desc)
      |> Map.new()

    %{
      total_n: total_n,
      total_pct: total_pct,
      man_n: man_n,
      man_pct: man_pct,
      woman_n: woman_n,
      woman_pct: woman_pct,
      famdoc_n: famdoc_n,
      famdoc_pct: famdoc_pct,
      famdocs_speak_pct: famdocs_speak_pct,
      specialties_n: specialties_n,
      lhins_n: lhins_n
    }
  end

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
