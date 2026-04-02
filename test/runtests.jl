using DSO
using Test
using Mocking

import DSO: dso_cli_available, run_dso, create, compile_config, repro, read_safe_yaml, read_params

@testset "DSO.jl" begin
    #
    # Test project when DSO cli is available
    #
    @testset "Project creation with CLI available" begin
        mktempdir() do tmp
            
            # Mock dso cli
            @mock dso_cli_available()=true begin
            @mock run_dso(cmd) = nothing begin

                # test if create can be executed
                result = create(
                    "project",
                    name = "AwesomeProject",
                    description = "Some amazing analysis",
                )
                @test result isa Bool
                @test result_create == true
            end; end
    end

    @testset "Project ceration without CLI available" begin
        mktempdir() do tmp

            @mock dso_cli_available() = false begin
                @test_throws ErrorException create_project(
                    "project",
                    name = "AwesomeProject",
                    description = "Some amazing analysis"
                )
            end

    end

    # mock read_safe_yaml to return a dict.
    
end
