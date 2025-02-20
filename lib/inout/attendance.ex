defmodule Inout.Server do
  use GenServer
  alias Inout.{Repo, User, Leave, Team}
  import Ecto.Query

  @moduledoc """
  A comprehensive attendance tracking system for employees.
  Tracks login times, calculates attendance, manages leaves, and more.
  """

  ## Public API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{attendance: %{}, leaves: %{}}, name: __MODULE__)
  end

  @doc """
  Registers a new employee with an ID and password.
  """
  def register_user(employee_id, password) do
    hashed_password = Bcrypt.hash_pwd_salt(password)

    %User{}
    |> User.changeset(%{"employee_id" => employee_id, "password_hash" => hashed_password})
    |> Repo.insert()
  end

  @doc """
  Authenticates an employee's login.
  """

  def authenticate(employee_id, password) do
    user = Repo.get_by(User, employee_id: employee_id)

    cond do
      user && Bcrypt.verify_pass(password, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, "Invalid password."}

      true ->
        {:error, "User not found."}
    end
  end

  @doc """
  Logs an employee's login time.
  """
  def log_in(employee_id) do
    GenServer.call(__MODULE__, {:log_in, employee_id})
  end

  @doc """
  Logs an employee's logout time and calculates attendance.
  """
  def log_out(employee_id) do
    GenServer.call(__MODULE__, {:log_out, employee_id})
  end

  @doc """
  Retrieves the attendance log for a specific employee.
  """
  def get_attendance(employee_id) do
    GenServer.call(__MODULE__, {:get_attendance, employee_id})
  end

  def get_teams do
    Repo.all(from t in Team, select: %{id: t.id, name: t.name})
  end


  @doc """
  Fetch last 10 login transactions.
  """
  def get_last_logins(employee_id, limit) do
    query =
      from l in "logins",
        where: l.employee_id == ^employee_id,
        order_by: [desc: l.inserted_at],
        limit: ^limit,
        select: %{login: l.login_time, logout: l.logout_time}

    Repo.all(query)
  end

  @doc """
  Expected login time from user profile.
  """
  def get_expected_login_time(employee_id) do
    user = Repo.get_by(User, employee_id: employee_id)
    user.expected_login_time || "09:00 AM"
  end

  @doc """
  Total allotted leaves.
  """
  def get_total_leaves(employee_id) do
    user = Repo.get_by(User, employee_id: employee_id)
    user.total_leaves || 20
  end

  @doc """
  Used leaves.
  """
  def get_used_leaves(employee_id) do
    query =
      from l in "leaves",
        where: l.employee_id == ^employee_id and l.status == "approved",
        select: count(l.id)

    Repo.one(query) || 0
  end

  @doc """
  Upcoming leaves.
  """
  def get_upcoming_leaves(employee_id) do
    today = Date.utc_today()

    query =
      from l in "leaves",
        where: l.employee_id == ^employee_id and l.start_date > ^today and l.status == "approved",
        select: %{date: l.start_date}

    Repo.all(query)
  end

  @doc """
  Applied leaves.
  """
  def get_applied_leaves(employee_id) do
    query =
      from l in "leaves",
        where: l.employee_id == ^employee_id,
        select: %{date: l.start_date, status: l.status}

    Repo.all(query)
  end

  @doc """
  Hours worked today.
  """
  def get_hours_worked_today(employee_id) do
    today = Date.utc_today()

    query =
      from l in "logins",
        where: l.employee_id == ^employee_id and fragment("date(?)", l.login_time) == ^today,
        select: %{login: l.login_time, logout: l.logout_time}

    Repo.all(query)
    |> Enum.reduce(0, fn %{login: login, logout: logout}, acc ->
      acc + DateTime.diff(logout || DateTime.utc_now(), login, :second)
    end)
    # Convert seconds to hours
    |> div(3600)
  end

  @doc """
  Average login time over the last 7 days.
  """
  def get_avg_login_time(employee_id) do
    # Get the start date and convert it to NaiveDateTime
    start_date = Date.add(Date.utc_today(), -7)
    naive_start_date = NaiveDateTime.new!(start_date, ~T[00:00:00])

    query =
      from l in "logins",
        where: l.employee_id == ^employee_id and l.login_time >= ^naive_start_date,
        select: l.login_time

    login_times = Repo.all(query)

    if login_times == [] do
      "N/A"
    else
      avg_minutes =
        login_times
        |> Enum.map(&DateTime.to_time/1)
        |> Enum.map(&(&1.hour * 60 + &1.minute))
        |> Enum.sum()
        |> div(length(login_times))

      {hour, minute} = rem(avg_minutes, 60)
      "#{pad_zero(hour)}:#{pad_zero(minute)}"
    end
  end

  defp pad_zero(num) when num < 10, do: "0#{num}"
  defp pad_zero(num), do: "#{num}"

  ## GenServer Callbacks

  def init(state) do
    {:ok, state}
  end

  def handle_call({:log_in, employee_id}, _from, state) do
    timestamp = DateTime.utc_now()

    updated_attendance =
      Map.update(state.attendance, employee_id, [%{login: timestamp}], fn logs ->
        [%{login: timestamp} | logs]
      end)

    {:reply, {:ok, timestamp}, %{state | attendance: updated_attendance}}
  end

  def handle_call({:log_out, employee_id}, _from, state) do
    timestamp = DateTime.utc_now()

    updated_attendance =
      Map.update(state.attendance, employee_id, [], fn logs ->
        case logs do
          [%{login: login_time} | rest] ->
            [%{login: login_time, logout: timestamp} | rest]

          _ ->
            logs
        end
      end)

    {:reply, {:ok, timestamp}, %{state | attendance: updated_attendance}}
  end

  def handle_call({:get_attendance, employee_id}, _from, state) do
    attendance = Map.get(state.attendance, employee_id, [])
    {:reply, attendance, state}
  end

  def get_members_on_leave_today do
    today = Date.utc_today()

    query = from l in Leave,
      join: u in User,
      on: l.employee_id == u.employee_id,  # Ensure employee_id is used correctly
      where: l.start_date <= ^today and l.end_date >= ^today and l.status == "approved",
      select: %{employee_id: u.employee_id, reason: l.reason}

    Repo.all(query)
  end

  # Function to load data for a specific team
  def load_team_data(team_id) do
    # Fetch team members
    team_members = Repo.all(from u in User, where: u.team_id == ^team_id)

    # Get last 10 logins for the team
    last_logins = Repo.all(
      from l in Login,
      where: l.team_id == ^team_id,
      order_by: [desc: l.login_time],
      limit: 10,
      select: %{employee_id: l.employee_id, login_time: l.login_time, logout_time: l.logout_time}
    )

    # Get members on leave today for this team
    today = Date.utc_today()
    members_on_leave_today = Repo.all(
      from l in Leave,
      join: u in User,
      on: l.employee_id == u.employee_id,
      where: l.team_id == ^team_id and l.start_date <= ^today and l.end_date >= ^today and l.status == "approved",
      select: %{employee_id: l.employee_id, reason: l.reason}
    )

    # Aggregate data for the team
    %{
      team_members: team_members,
      last_logins: last_logins,
      members_on_leave_today: members_on_leave_today
    }
  end
end
