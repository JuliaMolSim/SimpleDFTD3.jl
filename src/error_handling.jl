"""
    DFTD3Error(msg)

Exception raised when the s-dftd3 library reports an error.
"""
struct DFTD3Error <: Exception
    msg::String
end
Base.showerror(io::IO, e::DFTD3Error) = print(io, "DFTD3Error: ", e.msg)

const ERROR_BUFFER_SIZE = 1024

"""
    with_error(f)

Call `f(error_handle)` with a fresh s-dftd3 error handle, throw a
[`DFTD3Error`](@ref) if the library reported an error, and return the result of `f`.
"""
function with_error(f)
    err = LibSDFTD3.dftd3_new_error()
    err == C_NULL && throw(OutOfMemoryError())
    try
        result = f(err)
        if LibSDFTD3.dftd3_check_error(err) != 0
            buffer = zeros(UInt8, ERROR_BUFFER_SIZE)
            LibSDFTD3.dftd3_get_error(err, buffer, Ref(Cint(ERROR_BUFFER_SIZE)))
            throw(DFTD3Error(unsafe_string(pointer(buffer))))
        end
        result
    finally
        LibSDFTD3.dftd3_delete_error(Ref(err))
    end
end

# Shared helper for the handle-owning types below: get the C pointer or fail if the
# object was already finalised.
function checked_ptr(obj)
    obj.ptr == C_NULL && throw(ArgumentError("$(typeof(obj)) has already been finalized"))
    obj.ptr
end
