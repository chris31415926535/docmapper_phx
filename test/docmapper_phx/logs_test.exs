defmodule DocmapperPhx.LogsTest do
  use DocmapperPhx.DataCase

  alias DocmapperPhx.Logs

  describe "logs" do
    alias DocmapperPhx.Logs.Log

    import DocmapperPhx.LogsFixtures

    @invalid_attrs %{path: nil, ip: nil, lat: nil, lon: nil}

    test "list_logs/0 returns all logs" do
      log = log_fixture()
      assert Logs.list_logs() == [log]
    end

    test "get_log!/1 returns the log with given id" do
      log = log_fixture()
      assert Logs.get_log!(log.id) == log
    end

    test "create_log/1 with valid data creates a log" do
      valid_attrs = %{path: "some path", ip: "some ip", lat: 120.5, lon: 120.5}

      assert {:ok, %Log{} = log} = Logs.create_log(valid_attrs)
      assert log.path == "some path"
      assert log.ip == "some ip"
      assert log.lat == 120.5
      assert log.lon == 120.5
    end

    test "create_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logs.create_log(@invalid_attrs)
    end

    test "update_log/2 with valid data updates the log" do
      log = log_fixture()
      update_attrs = %{path: "some updated path", ip: "some updated ip", lat: 456.7, lon: 456.7}

      assert {:ok, %Log{} = log} = Logs.update_log(log, update_attrs)
      assert log.path == "some updated path"
      assert log.ip == "some updated ip"
      assert log.lat == 456.7
      assert log.lon == 456.7
    end

    test "update_log/2 with invalid data returns error changeset" do
      log = log_fixture()
      assert {:error, %Ecto.Changeset{}} = Logs.update_log(log, @invalid_attrs)
      assert log == Logs.get_log!(log.id)
    end

    test "delete_log/1 deletes the log" do
      log = log_fixture()
      assert {:ok, %Log{}} = Logs.delete_log(log)
      assert_raise Ecto.NoResultsError, fn -> Logs.get_log!(log.id) end
    end

    test "change_log/1 returns a log changeset" do
      log = log_fixture()
      assert %Ecto.Changeset{} = Logs.change_log(log)
    end
  end
end
