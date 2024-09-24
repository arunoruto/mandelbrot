function mandelbrot_normal(c, maxiter::Int=500)
    z = zeros(Complex{Float64}, size(c))
    result = ones(size(c)) * maxiter
    for i = 1:size(c, 1)
        for j = 1:size(c, 2)
            for n = 1:maxiter
                if abs2(z[i, j]) > 4.0
                    result[i, j] = n
                    break
                end
                z[i, j] = z[i, j] * z[i, j] + c[i, j]
            end
        end
    end

    result ./= maxiter

    return result
end

scale = 1000
maxiter = 500

left = -2.0
right = 1.0
bottom = -1.5
top = 1.5
width = Int((right - left) * scale)
height = Int((top - bottom) * scale)

x = range(left, stop=right, length=width)
y = range(bottom, stop=top, length=height)
c = [complex(r, i) for r in x, i in y]

mbs = mandelbrot_normal(c, maxiter)

using PlotlyJS
plot(
    heatmap(
        x=x,
        y=y,
        z=transpose(mbs),
    ),
    Layout(
        yaxis=attr(
            scaleanchor="x",
            scaleratio=1
        )
    )
)
