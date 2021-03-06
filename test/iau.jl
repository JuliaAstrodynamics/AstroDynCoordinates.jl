using RemoteFiles
using SPICE
import AstroTime

const PCK_FILE = @RemoteFile "https://naif.jpl.nasa.gov/pub/naif/generic_kernels/pck/pck00010.tpc"

download(PCK_FILE)
furnsh(path(PCK_FILE))

@testset "IAU" begin
    # Reference data from SPICE
    ep = TDBEpoch(UTCEpoch(2017, 3, 25, 17, 4, 23.789))
    jd = get(seconds(AstroTime.j2000(ep)))
    @testset for body in (PLANET_NAMES..., SATELLITE_NAMES...)
        @eval b = $body
        @eval f = $(Symbol("IAU", body))
        ref = tisbod("J2000", naif_id(b), jd)
        m = ref[1:3,1:3]
        δm = ref[4:6,1:3]
        rot = Rotation(GCRF, f, ep)
        @test rot isa Rotation{GCRF, f}
        @test rot.m ≈  m
        @test rot.δm ≈  δm
    end
    rot = Rotation(IAUEarth, GCRF, ep)
    ref = tisbod("J2000", naif_id(Earth), jd)
    m = ref[1:3,1:3]'
    δm = ref[4:6,1:3]'
    @test rot isa Rotation{IAUEarth, GCRF}
    @test rot.m ≈ m
    @test rot.δm ≈ δm
end
