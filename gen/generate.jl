# Regenerate all files in src/gen. Run from the repository root with
#     julia --project=gen gen/generate.jl

using Clang.Generators
using simple_dftd3_jll

# The header only names arguments in comments, e.g. `const int /* natoms */`.
# Turn these into real parameter names so the generated wrappers get meaningful
# argument names, and give K&R-style empty argument lists an explicit `void`.
function preprocess_header(src::AbstractString)
    # `TYPE /* name [dims] */,`  →  `TYPE name /* [dims] */,`
    src = replace(src, r"/\*\s*(\w+)\s*([^*]*?)\s*\*/(?=\s*[,)])" =>
                       s -> begin
                           m = match(r"/\*\s*(\w+)\s*([^*]*?)\s*\*/", s)
                           isempty(m[2]) ? m[1] : string(m[1], " /* ", m[2], " */")
                       end)
    # `dftd3_get_version()`  →  `dftd3_get_version(void)`
    replace(src, r"(\bdftd3_\w+)\(\)" => s"\1(void)")
end

targetdir = normpath(joinpath(@__DIR__, "..", "src", "gen"))

include_dir = normpath(simple_dftd3_jll.artifact_dir, "include")
header = joinpath(include_dir, "s-dftd3.h")
isfile(header) || error("s-dftd3.h not found in $include_dir")

workdir = mktempdir()
processed = joinpath(workdir, "s-dftd3.h")
write(processed, preprocess_header(read(header, String)))

options = load_options(joinpath(@__DIR__, "generator.toml"))
options["general"]["output_file_path"] = joinpath(targetdir, "LibSDFTD3.jl")
options["general"]["prologue_file_path"] = joinpath(@__DIR__, "prologue.jl")

args = get_default_args()
push!(args, "-I$include_dir")

ctx = create_context([processed], args, options)
build!(ctx)
