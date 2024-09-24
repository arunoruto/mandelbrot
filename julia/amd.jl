ENV["LD_LIBRARY_PATH"] = ENV["NIX_LD_LIBRARY_PATH"]
ENV["HSA_OVERRIDE_GFX_VERSION"] = "11.0.0"

using AMDGPU

function mandelbrot_amd!(result, c, maxiter::Int=500)
    k = workitemIdx().x + (workgroupIdx().x - 1) * workgroupDim().x
    i = (k - 1) % size(c, 1) + 1
    j = (k - 1) ÷ size(c, 1) + 1

    if (i > size(c, 1)) || (j > size(c, 2))
        return
    end

    z = Complex(0.0, 0.0)
    result[i, j] = 1.0
    for n = 1:maxiter
        if abs2(z) > 4.0
            result[i, j] = n / maxiter
            break
        end
        z = z * z + c[i, j]
    end
end

scale = 2000
maxiter = 500

left = -2.0
right = 1.0
bottom = -1.5
top = 1.5
width = Int((right - left) * scale)
height = Int((top - bottom) * scale)

x = range(left, stop=right, length=width)
y = range(bottom, stop=top, length=height)
c = ROCArray([complex(r, i) for r in x, i in y])

groupsize = 256
gridsize = cld(width * height, groupsize)

mbs = AMDGPU.ones(Float64, size(c))
time_elapsed = @elapsed begin
    @roc groupsize=groupsize gridsize=gridsize mandelbrot_amd!(mbs, c, maxiter)
end
println("Time: $time_elapsed")

# using PlotlyJS
# plot(
#     heatmap(
#         x=x,
#         y=y,
#         z=transpose(Array(mbs)),
#     ),
#     Layout(
#         yaxis=attr(
#             scaleanchor="x",
#             scaleratio=1
#         )
#     )
# )