using Test
# include("DsoParams.jl") # Uncomment if running standalone

@testset "DsoParams Functionality" begin
    # Initial data for testing
    initial_dict = Dict(:alpha => 10, :beta => "system")
    params = DsoParams(initial_dict)

    @testset "Initialization & Access" begin
        # Test that data is stored correctly
        @test params.data == initial_dict
        
        # Test dot notation getter 
        @test params.alpha == 10
        @test params.beta == "system"
        
        # Test getfield for the actual data container 
        @test getfield(params, :data) isa Dict
    end

    @testset "Property Assignment & Safety" begin
        # Test dot notation setter
        params.gamma = [1, 2, 3]
        @test params.gamma == [1, 2, 3]
        
        # Test that the underlying Dict is updated 
        @test params.data[:gamma] == [1, 2, 3]
        
        # Test protection against overwriting the 'data' field 
        @test_throws ErrorException params.data = Dict(:new => 1)
    end

    @testset "Collection Interface" begin
        # Test index-based access and assignment 
        params[:delta] = 42
        @test params[:delta] == 42
        
        # Test length and haskey 
        @test length(params) == 4
        @test haskey(params, :alpha) == true
        @test haskey(params, :omega) == false
        
        # Test keys and values 
        @test :alpha in keys(params)
        @test 42 in values(params)
        
        # Test get_keys utility
        @test :delta in get_keys(params)
    end

    @testset "Introspection & Display" begin
        # Test propertynames for autocompletion 
        p_names = propertynames(params)
        @test :data in p_names
        @test :alpha in p_names
        @test :delta in p_names

        # Test show methods (checking for no errors)
        @test_nowarn show(devnull, params)
        @test_nowarn show(devnull, "text/plain", params)
    end
end