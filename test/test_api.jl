using Test
using FilePathsBase
using YAML

# Ensure dependent files are loaded
# include("config.jl")
# include("DsoParams.jl")
# include("util.jl")
# include("api.jl")

# Setup: Global CONFIG instance as expected by api.jl
const CONFIG = Config()

@testset "api.jl Unit Tests" begin
    # Create a mock project structure
    mktempdir() do tmpdir
        cd(tmpdir) do
            # Mock a git repository to define project root
            mkdir(".git")
            
            # Create a dummy stage directory
            stage_name = "test_stage"
            mkdir(stage_name)
            
            @testset "Path Management" begin
                # Test here()
                @test here() == tmpdir
                @test here("data.csv") == joinpath(tmpdir, "data.csv")

                # Test stage_here() before setting stage (should throw)
                @test_throws ErrorException stage_here()

                # Test set_stage()
                @test_nowarn set_stage(stage_name)
                @test CONFIG.stage_here == FilePathsBase.PosixPath(joinpath(tmpdir, stage_name))

                # Test stage_here() after setting
                @test stage_here() == joinpath(tmpdir, stage_name)
                @test stage_here("results") == joinpath(tmpdir, stage_name, "results")
                
                # Test set_stage with non-existent directory
                @test_throws ArgumentError set_stage("non_existent_folder")
            end

            @testset "YAML & Params" begin
                # Test read_safe_yaml() 
                test_yaml = joinpath(tmpdir, "params.yaml")
                YAML.write_file(test_yaml, Dict("learning_rate" => 0.01, "epochs" => 10))
                
                data = read_safe_yaml(test_yaml)
                @test data["learning_rate"] == 0.01
                @test data["epochs"] == 10

                # Note: read_params() requires dso-cli to be installed.
                # If dso-cli is missing, it should throw an error.
                try
                    dso_cli_available()
                    # If CLI exists, we could test read_params logic here
                catch
                    @testset "CLI Availability Guard" begin
                        @test_throws ErrorException read_params(stage_name)
                    end
                end
            end

            @testset "CLI Command Wrappers" begin
                # Test create() validation
                @test_throws ErrorException create("project", name=nothing, description="test")
                @test_throws ErrorException create("project", name="new_proj", description=nothing)
                @test_throws ErrorException create("invalid_type", name="a", description="b")

                # Test repro() validation
                # Should fail because dvc.yaml doesn't exist
                @test_throws ErrorException repro()
            end
        end
    end
end