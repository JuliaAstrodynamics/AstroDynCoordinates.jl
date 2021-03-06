using AstroTime
using StaticArrays

import AstroBase: velocity, position, state
import AstroDynBase: AbstractState, keplerian,
    Rotation, period, epoch
import Base: show, isapprox, ==

export State, ThreeBodyState, period
export timescale, frame, body, primary, secondary, keplerian, position, velocity,
    epoch, isapprox, ==, array, semimajor, eccentricity, inclination,
    ascendingnode, argofpericenter, trueanomaly

struct State{
        F<:Frame,
        S, T,
        C<:CelestialBody,
        R, V,
    } <: AbstractState
    epoch::Epoch{S, T}
    r::SVector{3,R}
    v::SVector{3,V}

    function State(ep::Epoch{S,T}, r, v,
        frame::Type{F}=GCRF, body::Type{C}=Earth) where {
        F<:Frame, T, S, C<:CelestialBody}
        R = eltype(r)
        V = eltype(v)
        new{F,S,T,C,R,V}(ep, r, v)
    end
end

function State(ep::Epoch,
    sma, ecc, inc, node, peri, ano,
    frame::Type{F}=GCRF, body::Type{C}=Earth) where {F<:Frame,C<:CelestialBody}
    r, v = cartesian(sma, ecc, inc, node, peri, ano, μ(body))
    State(ep, r, v, frame, body)
end

function State(ep::Epoch, rv,
    frame::Type{F}=GCRF, body::Type{C}=Earth) where {F<:Frame,C<:CelestialBody}
    State(ep, rv[1], rv[2], frame, body)
end

function State(ep::Epoch, rv::AbstractArray,
    frame::Type{F}=GCRF, body::Type{C}=Earth) where {F<:Frame,C<:CelestialBody}
    State(ep, rv[1:3], rv[4:6], frame, body)
end

position(s::State) = s.r
velocity(s::State) = s.v
array(s::State) = Array([s.r; s.v])
epoch(s::State) = s.epoch
keplerian(s::State) = keplerian(position(s), velocity(s), μ(body(s)))

function period(s::State)
    ele = keplerian(s)
    period(ele[1], μ(body(s)))
end

semimajor(s::State) = keplerian(s)[1]
eccentricity(s::State) = keplerian(s)[2]
inclination(s::State) = keplerian(s)[3]
ascendingnode(s::State) = keplerian(s)[4]
argofpericenter(s::State) = keplerian(s)[5]
trueanomaly(s::State) = keplerian(s)[6]
frame(::State{F}) where F<:Frame = F
const _frame = frame
timescale(::State{<:Any, T}) where {T} = T
const _timescale = timescale
body(::State{<:Any, <:Any, <:Any, C}) where C<:CelestialBody = C
const _body = body
(rot::Rotation)(s::State) = rot(position(s), velocity(s))
splitrv(arr) = arr[1:3], arr[4:6]

function State(s::State{F1, T1, S, C1};
    frame::Type{F2}=_frame(s), timescale::T2=_timescale(s),
    body::Type{C2}=_body(s)) where {F1<:Frame, F2<:Frame,
    T1, T2, S, C1<:CelestialBody, C2<:CelestialBody}
    convert(State{F2, T2, S, C2}, s)
end

function (==)(s1::State{F, S, T, C}, s2::State{F, S, T, C}) where {
    F<:Frame, S, T, C<:CelestialBody}
    s1.epoch == s2.epoch && s1.r == s2.r && s1.v == s2.v
end
#= (==)(s1::State{<:Frame, , <:CelestialBody}, =#
#=     s2::State{<:Frame, , <:CelestialBody}) = false =#

function isapprox(s1::State{F, S, T, C}, s2::State{F, S, T, C}) where {
    F<:Frame, S, T, C<:CelestialBody}
    s1.epoch ≈ s2.epoch && s1.r ≈ s2.r && s1.v ≈ s2.v
end
#= isapprox(s1::State{<:Frame, , <:CelestialBody}, =#
#=     s2::State{<:Frame, , <:CelestialBody}) = false =#

function show(io::IO, s::State)
    sma, ecc, inc, node, peri, ano = keplerian(s)
    print(io, "State{",
    frame(s), ", ",
    timescale(s), ", ",
    body(s), "}\n",
    " Epoch: ", s.epoch, "\n",
    " Frame: ", frame(s), "\n",
    " Body:  ", body(s), "\n\n",
    " rx: ", s.r[1], "\n",
    " ry: ", s.r[2], "\n",
    " rz: ", s.r[3], "\n",
    " vx: ", s.v[1], "\n",
    " vy: ", s.v[2], "\n",
    " vz: ", s.v[3], "\n\n",
    " a: ", sma, "\n",
    " e: ", ecc, "\n",
    " i: ", rad2deg(inc), "\n",
    " ω: ", rad2deg(node), "\n",
    " Ω: ", rad2deg(peri), "\n",
    " ν: ", rad2deg(ano))
end
#=  =#
#= struct ThreeBodyState{ =#
#=         F<:Frame, =#
#=         T, =#
#=         C1<:CelestialBody, =#
#=         C2<:CelestialBody, =#
#=     } <: AbstractState =#
#=     ep::Epoch{T} =#
#=     r::SVector{3,Float64} =#
#=     v::SVector{3,Float64} =#
#=  =#
#=     function ThreeBodyState( =#
#=         ep::Epoch{T}, r, v, frame::Type{F}=GCRF, =#
#=         primary::Type{C1}=Sun, secondary::Type{C2}=Earth =#
#=     ) where {T,F<:Frame,C1<:CelestialBody,C2<:CelestialBody} =#
#=         new{F, T, C1, C2}(ep, r, v) =#
#=     end =#
#= end =#
#=  =#
#= frame(::ThreeBodyState{F}) where F<:Frame = F =#
#= timescale(::ThreeBodyState{<:Frame, T}) where T = T =#
#= primary(::ThreeBodyState{<:Frame,,C}) where C<:CelestialBody = C =#
#= secondary(::ThreeBodyState{<:Frame,,<:CelestialBody,C}) where { =#
#=     C<:CelestialBody} = C =#
