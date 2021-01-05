# Increase parallelism, as tests are mostly IO-bound
ExUnit.configure(max_cases: System.schedulers_online() * 4)
ExUnit.start()

{:ok, _agent} = Gestalt.start()
