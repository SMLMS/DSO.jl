using DSO
using Test

import DSO: create, compile_config, repro, read_params, DsoParams, Config, here, stage_here, set_stage, session_info


@testset "Project creation with CLI available" begin
    temp_dir = mktempdir() do tmp
        cd(tmp) do
            result = create(
                "project",
                dir=tmp,
                name="AwesomeProject",
                description = "Some amazing analysis",
                dso_available = () -> true,
                run_dso = (command::Base.CmdRedirect, tmp_err_file::AbstractString) -> nothing
            )
            @test result isa Bool
            @test result == true
        end
    end
end

@testset "Project creation without CLI available" begin
    temp_dir = mktempdir() do tmp
        cd(tmp) do
            result = create(
                "project",
                dir=tmp,
                name="AwesomeProject",
                description = "Some amazing analysis",
                dso_available = () -> false,
                run_dso = (command::Base.CmdRedirect, tmp_err_file::AbstractString) -> nothing
            )
            @test result isa Bool
            @test result == false
        end
    end
end

@testset "Compile configuration with CLI available" begin
    temp_dir = mktempdir() do tmp
        # mock dso environment
        path_to_git = joinpath(tmp, ".git")
        path_to_stage = joinpath(tmp, "01_stage")
        path_to_project_config = joinpath(tmp, "dvc.yaml")
        path_to_stage_config = joinpath(path_to_stage, "dvc.yaml")
        mkdir(path_to_git)
        mkdir(path_to_stage)
        open(path_to_project_config, "w") do file
            write(file, "project config params go here")
        end
        open(path_to_stage_config, "w") do file
            write(file, "stage config params go here")
        end

        # run tests
        cd(path_to_stage) do
            result = compile_config(
                dso_available = () -> true,
                run_dso = (command::Base.CmdRedirect, tmp_err_file::AbstractString) -> nothing
            )
            @test result isa Bool
            @test result == true
        end

        # clean up mock dso environment
        rm(path_to_stage_config, force=true)
        rm(path_to_project_config, force=true)
        rm(path_to_stage, force=true)
        rm(path_to_git, force=true)
    end
end

@testset "Compile configuration without CLI available" begin
    temp_dir = mktempdir() do tmp
        result = compile_config(
            tmp,
            dso_available = () -> false,
            run_dso = (command::Base.CmdRedirect, tmp_err_file::AbstractString) -> nothing
        )
        @test result isa Bool
        @test result == false
    end
end


@testset "Reproduce results with CLI available" begin
    temp_dir = mktempdir() do tmp
        config_file = joinpath(tmp, "dvc.yaml")
        open(config_file, "w") do io 
            write(io, "param: 'Awesome parameter\n'")
        end
        result = repro(
            stage_dir = tmp,
            dso_available = () -> true,
            run_dso = (command::Base.CmdRedirect, tmp_err_file::AbstractString) -> nothing
        )
        rm(config_file, force=true)
        @test result isa Bool
        @test result == true
    end
end

@testset "Reproduce results without CLI available" begin
    temp_dir = mktempdir() do tmp
        config_file = joinpath(tmp, "dvc.yaml")
        open(config_file, "w") do io 
            write(io, "param: 'Awesome parameter\n'")
        end
        result = repro(
            stage_dir = tmp,
            dso_available = () -> false,
            run_dso = (command::Base.CmdRedirect, tmp_err_file::AbstractString) -> nothing
        )
        rm(config_file, force=true)
        @test result isa Bool
        @test result == false
    end
end



@testset "read params without CLI available" begin
    temp_dir = mktempdir() do tmp
        # mock dso environment
        path_to_git = joinpath(tmp, ".git")
        path_to_stage = joinpath(tmp, "01_stage")
        path_to_project_config = joinpath(tmp, "dvc.yaml")
        path_to_stage_config = joinpath(path_to_stage, "dvc.yaml")
        mkdir(path_to_git)
        mkdir(path_to_stage)
        open(path_to_project_config, "w") do file
            write(file, "project config params go here")
        end
        open(path_to_stage_config, "w") do file
            write(file, "stage config params go here")
        end
        params_dict =  Dict(:param => "the world best parameter")
        # run tests
        cd(path_to_stage) do
            result_dict = read_params(
                path_to_stage,
                return_dict = true,
                dso_available = () -> true,
                run_dso = (command::Base.CmdRedirect, tmp_err_file::AbstractString) -> nothing,
                read_yaml = (params_file::AbstractString) -> params_dict
            )
            @test result_dict isa Dict
            @test result_dict[:param] == "the world best parameter"

            result_obj = read_params(
                path_to_stage,
                dso_available = () -> true,
                run_dso = (command::Base.CmdRedirect, tmp_err_file::AbstractString) -> nothing,
                read_yaml = (params_file::AbstractString) -> params_dict
            )
            @test result_obj isa DsoParams
            @test result_obj.param == "the world best parameter"
        end

        # clean up mock dso environment
        rm(path_to_stage_config, force=true)
        rm(path_to_project_config, force=true)
        rm(path_to_stage, force=true)
        rm(path_to_git, force=true)
    end
end

@testset "Test DsoParams object" begin
    params_dict = Dict(:param_01 => "the world best parameter")
    params_obj = DsoParams(params_dict)
    @test params_obj.param_01 == "the world best parameter"
    params_obj.param_01 = "an even better parameter"
    @test params_obj.param_01 == "an even better parameter"
    params_obj.param_02 = "the second best parameter"
    @test params_obj.param_02 == "the second best parameter"
    @test sort(get_keys(params_obj)) == sort([:param_01, :param_02])
end

@testset "test stage functions" begin
    temp_dir = mktempdir() do tmp
        # mock dso environment
        path_to_git = joinpath(tmp, ".git")
        path_to_stage = joinpath(tmp, "01_stage")
        path_to_project_config = joinpath(tmp, "dvc.yaml")
        path_to_toml = joinpath(tmp, "Project.toml")
        path_to_stage_config = joinpath(path_to_stage, "dvc.yaml")
        open(path_to_toml, "w") do file
            write(file, "[deps]\nDSO = '1ecce73e-f1b1-49c8-92b6-7d632d350df1'\n")
        end
        mkdir(path_to_git)
        mkdir(path_to_stage)
        open(path_to_project_config, "w") do file
            write(file, "project config params go here")
        end
        open(path_to_stage_config, "w") do file
            write(file, "stage config params go here")
        end
        params_dict =  Dict(:param => "the world best parameter")
        # run tests
        cd(path_to_stage) do
            @test here() == tmp
            @test here("01_stage") == path_to_stage
            set_stage("01_stage")
            @test string(DSO.CONFIG.stage_here) == path_to_stage
            @test stage_here("new_output.csv") == joinpath(path_to_stage, "new_output.csv")
            @test session_info() == nothing
        end
    end
end