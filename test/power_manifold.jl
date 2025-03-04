include("utils.jl")

using HybridArrays, Random

Random.seed!(42)

@testset "Power manifold" begin

    Ms = Sphere(2)
    Ms1 = PowerManifold(Ms, 5)
    Ms2 = PowerManifold(Ms, 5, 7)
    Mr = Manifolds.Rotations(3)
    Mr1 = PowerManifold(Mr, 5)
    Mr2 = PowerManifold(Mr, 5, 7)

    types_s1 = [Array{Float64,2},
                HybridArray{Tuple{3,StaticArrays.Dynamic()}, Float64, 2}]
    types_s2 = [Array{Float64,3},
                HybridArray{Tuple{3,StaticArrays.Dynamic(),StaticArrays.Dynamic()}, Float64, 3}]

    types_r1 = [Array{Float64,3},
                HybridArray{Tuple{3,3,StaticArrays.Dynamic()}, Float64, 3}]
    types_r2 = [Array{Float64,4},
                HybridArray{Tuple{3,3,StaticArrays.Dynamic(),StaticArrays.Dynamic()}, Float64, 4}]

    retraction_methods = [Manifolds.PowerRetraction(ManifoldsBase.ExponentialRetraction())]
    inverse_retraction_methods = [Manifolds.InversePowerRetraction(ManifoldsBase.LogarithmicInverseRetraction())]

    sphere_dist = Manifolds.uniform_distribution(Ms, @SVector [1.0, 0.0, 0.0])
    power_s1_pt_dist = Manifolds.PowerPointDistribution(Ms1, sphere_dist, randn(Float64, 3, 5))
    power_s2_pt_dist = Manifolds.PowerPointDistribution(Ms2, sphere_dist, randn(Float64, 3, 5, 7))
    sphere_tv_dist = Manifolds.normal_tvector_distribution(Ms, (@MVector [1.0, 0.0, 0.0]), 1.0)
    power_s1_tv_dist = Manifolds.PowerFVectorDistribution(TangentBundleFibers(Ms1), rand(power_s1_pt_dist), sphere_tv_dist)
    power_s2_tv_dist = Manifolds.PowerFVectorDistribution(TangentBundleFibers(Ms2), rand(power_s2_pt_dist), sphere_tv_dist)

    id_rot = @SMatrix [1.0 0.0 0.0; 0.0 1.0 0.0; 0.0 0.0 1.0]
    rotations_dist = Manifolds.normal_rotation_distribution(Mr, id_rot, 1.0)
    power_r1_pt_dist = Manifolds.PowerPointDistribution(Mr1, rotations_dist, randn(Float64, 3, 3, 5))
    power_r2_pt_dist = Manifolds.PowerPointDistribution(Mr2, rotations_dist, randn(Float64, 3, 3, 5, 7))
    rotations_tv_dist = Manifolds.normal_tvector_distribution(Mr, MMatrix(id_rot), 1.0)
    power_r1_tv_dist = Manifolds.PowerFVectorDistribution(TangentBundleFibers(Mr1), rand(power_r1_pt_dist), rotations_tv_dist)
    power_r2_tv_dist = Manifolds.PowerFVectorDistribution(TangentBundleFibers(Mr2), rand(power_r2_pt_dist), rotations_tv_dist)

    trim(s::String) = s[1:min(length(s), 20)]

    for T in types_s1
        @testset "Type $(trim(string(T)))..." begin
            pts1 = [convert(T, rand(power_s1_pt_dist)) for _ in 1:3]
            test_manifold(Ms1,
                          pts1;
                          test_reverse_diff = true,
                          test_musical_isomorphisms = true,
                          retraction_methods = retraction_methods,
                          inverse_retraction_methods = inverse_retraction_methods,
                          point_distributions = [power_s1_pt_dist],
                          tvector_distributions = [power_s1_tv_dist],
                          rand_tvector_atol_multiplier = 6.0)
        end
    end
    for T in types_s2
        @testset "Type $(trim(string(T)))..." begin
            pts2 = [convert(T, rand(power_s2_pt_dist)) for _ in 1:3]
            test_manifold(Ms2,
                          pts2;
                          test_reverse_diff = true,
                          test_musical_isomorphisms = true,
                          retraction_methods = retraction_methods,
                          inverse_retraction_methods = inverse_retraction_methods,
                          point_distributions = [power_s2_pt_dist],
                          tvector_distributions = [power_s2_tv_dist],
                          rand_tvector_atol_multiplier = 6.0)
        end
    end

    for T in types_r1
        @testset "Type $(trim(string(T)))..." begin
            pts1 = [convert(T, rand(power_r1_pt_dist)) for _ in 1:3]
            test_manifold(Mr1,
                          pts1;
                          test_reverse_diff = false,
                          test_musical_isomorphisms = true,
                          retraction_methods = retraction_methods,
                          inverse_retraction_methods = inverse_retraction_methods,
                          point_distributions = [power_r1_pt_dist],
                          tvector_distributions = [power_r1_tv_dist],
                          rand_tvector_atol_multiplier = 5.0)
        end
    end
    for T in types_r2
        @testset "Type $(trim(string(T)))..." begin
            pts2 = [convert(T, rand(power_r2_pt_dist)) for _ in 1:3]
            test_manifold(Mr2,
                          pts2;
                          test_reverse_diff = false,
                          test_musical_isomorphisms = true,
                          retraction_methods = retraction_methods,
                          inverse_retraction_methods = inverse_retraction_methods,
                          point_distributions = [power_r2_pt_dist],
                          tvector_distributions = [power_r2_tv_dist],
                          rand_tvector_atol_multiplier = 5.0)
        end
    end

end
