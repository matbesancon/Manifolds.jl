include("utils.jl")

M1 = Manifolds.SymmetricPositiveDefinite(3)
M2 = MetricManifold(Manifolds.SymmetricPositiveDefinite(3), Manifolds.LinearAffineMetric())
M3 = MetricManifold(Manifolds.SymmetricPositiveDefinite(3), Manifolds.LogCholeskyMetric())

types = [ Matrix{Float32},
        Matrix{Float64},
        MMatrix{3,3,Float32},
        # linear algebra in StataicArrays is a little too inaccurate for MMatrix{3,3,Float64}
        # MMatrix{3,3,Float64}
    ]
for M in [M1, M2, M3]
    @testset "$(typeof(M))" begin
        for T in types
            if M == M3 && T <: MMatrix
                #TODO fix the issue that causes this failure
                continue
            end
            A(α) = [1. 0. 0.; 0. cos(α) sin(α); 0. -sin(α) cos(α)]
            ptsF = [#
                [1. 0. 0.; 0. 1. 0.; 0. 0. 1],
                [2. 0. 0.; 0. 2. 0.; 0. 0. 1],
                A(π/6) * [1. 0. 0.; 0. 2. 0.; 0. 0. 1] * transpose(A(π/6)),
            ]
            pts = [convert(T, a) for a in ptsF]
            test_manifold(M, pts;
                test_vector_transport = true,
                test_forward_diff = false,
                test_reverse_diff = false,
                exp_log_atol_multiplier = 8
            )
        end
        @testset "Test Error cases in is_manifold_point and is_tangent_vector" begin
            pt1f = zeros(2,3); # wrong size
            pt2f = [1. 0. 0.; 0. 0. 0.; 0. 0. 1.]; # not positive Definite
            pt3f = [2. 0. 1.; 0. 1. 0.; 0. 0. 4.]; # not symmetric
            pt4 = [2. 1. 0.; 1. 2. 0.; 0. 0. 4.]
            @test !is_manifold_point(M,pt1f)
            @test !is_manifold_point(M,pt2f)
            @test !is_manifold_point(M,pt3f)
            @test is_manifold_point(M, pt4)
            @test !is_tangent_vector(M,pt4, pt1f)
            @test is_tangent_vector(M,pt4, pt2f)
            @test !is_tangent_vector(M,pt4, pt3f)
        end
    end
end
