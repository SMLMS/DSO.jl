using DSO
using Test
using Mocking

import DSO: dso_cli_available, run_dso, create, compile_config, repro, read_safe_yaml, read_params

Mocking.activate()



@testset "Project creation with CLI available" begin
    #dso_cli_available = @mock dso_cli_available();
    temp_dir = mktempdir() do tmp
        # define patches
        patch_dso_available = @patch DSO.dso_cli_available() = false ;
        #patch_run_dso = @patch run_dso(::Base.CmdRedirect) = nothing ;

        # apply patches in tests
        Mocking.apply([patch_dso_available]) do
            cd(tmp) do
                result = create(
                    "project",
                    dir=tmp,
                    name="AwesomeProject",
                    description = "Some amazing analysis"
                )
                @test result isa Bool
                @test result === true
            end
        end
    end
end

