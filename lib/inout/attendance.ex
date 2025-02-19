defmodule Inout.Server do
  use GenServer

  @moduledoc """
  A simple attendance tracking system for employees.
  Tracks login times and calculates total attendance.
  """

  ## Public API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
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

  ## GenServer Callbacks

  def init(state) do
    {:ok, state}
  end

  def handle_call({:log_in, employee_id}, _from, state) do
    timestamp = DateTime.utc_now()
    updated_state = Map.update(state, employee_id, [%{login: timestamp}], fn logs ->
      [%{login: timestamp} | logs]
    end)

    {:reply, {:ok, timestamp}, updated_state}
  end

  def handle_call({:log_out, employee_id}, _from, state) do
    timestamp = DateTime.utc_now()

    updated_state = Map.update(state, employee_id, [], fn logs ->
      case logs do
        [%{login: login_time} | rest] ->
          [%{login: login_time, logout: timestamp} | rest]
        _ ->
          logs
      end
    end)

    {:reply, {:ok, timestamp}, updated_state}
  end

  def handle_call({:get_attendance, employee_id}, _from, state) do
    attendance = Map.get(state, employee_id, [])
    {:reply, attendance, state}
  end
end
