#!/usr/bin/env python
### hilbert.py -- Hilbert walk coordinate codec in multiple dimensions.
#    int_to_Hilbert( i, 3 ) ==> ( x, y, z )
#        int_to_Hilbert( 0, nD ) ==> ( 0, 0, 0, ... 0 ) Start at origin.
#        int_to_Hilbert( 1, nD ) ==> ( 1, 0, 0, ... 0 ) 1st step is along x.
#    Hilbert_to_int( ( x, y, z ) ) ==> i
# Steve Witham ess doubleyou at tiac remove-this dot net.
# http://www.tiac.net/~sw/2008/10/Hilbert


from sys import argv
from math import log, ceil


def int_to_Hilbert( i, nD=2 ):  # Default is the 2D Hilbert walk.
    index_chunks = unpack_index( i, nD )
    nChunks = len( index_chunks )
    mask = 2 ** nD - 1
    start, end = initial_start_end( nChunks, nD )
    coord_chunks = [0] * nChunks
    for j in range( nChunks ):
        i = index_chunks[ j ]
        coord_chunks[ j ] = gray_encode_travel( start, end, mask, i )
        start, end = child_start_end( start, end, mask, i )
    return pack_coords( coord_chunks, nD )


def Hilbert_to_int( coords ):
    nD = len( coords )
    coord_chunks = unpack_coords( coords )
    nChunks = len( coord_chunks )
    mask = 2 ** nD - 1
    start, end = initial_start_end( nChunks, nD )
    index_chunks = [0] * nChunks
    for j in range( nChunks ):
        i = gray_decode_travel( start, end, mask, coord_chunks[ j ] )
        index_chunks[ j ] = i
        start, end = child_start_end( start, end, mask, i )
    return pack_index( index_chunks, nD )
      

def initial_start_end( nChunks, nD ):
    # This orients the largest cube so that 
    # its start is the origin (0 corner), and
    # the first step is along the x axis, regardless of nD and nChunks:
    return 0,  2**( ( -nChunks - 1 ) % nD )  # in Python 0 <=  a % b  < b.


# Unpacking arguments and packing results of int <-> Hilbert functions.
# nD == # of dimensions.  
# A "chunk" is an nD-bit int (or Python long, aka bignum).
# Lists of chunks are highest-order first.
# Bits within "coord chunks" are x highest-order, y next, etc.,
# i.e., the same order as coordinates input to Hilbert_to_int()
# and output from int_to_Hilbert().


## unpack_index( int index, nD ) --> list of index chunks.
#
def unpack_index( i, nD ):
    p = 2**nD     # Chunks are like digits in base 2**nD.
    nChunks = max( 1, int( ceil( log( i + 1, p ) ) ) ) #   # of digits
    chunks = [ 0 ] * nChunks
    for j in range( nChunks - 1, -1, -1 ):
        chunks[ j ] = i % p
        i /= p
    return chunks

def pack_index( chunks, nD ):
    p = 2**nD  # Turn digits mod 2**nD back into a single number:
    return reduce( lambda n, chunk: n * p + chunk, chunks )


## unpack_coords( list of nD coords ) --> list of coord chunks each nD bits.
def unpack_coords( coords ):
    nD = len( coords )
    biggest = reduce( max, coords )  # the max of all coords
    nChunks = max( 1, int( ceil( log( biggest + 1, 2 ) ) ) ) # max # of bits
    return transpose_bits( coords, nChunks )

def pack_coords( chunks, nD ):
    return transpose_bits( chunks, nD )


## transpose_bits -- 
#    Given nSrcs source ints each nDests bits long,
#    return nDests ints each nSrcs bits long.
#    Like a matrix transpose where ints are rows and bits are columns.
#    Earlier srcs become higher bits in dests;
#    earlier dests come from higher bits of srcs.
def transpose_bits( srcs, nDests ):
    srcs = list( srcs )  # Make a copy we can modify safely.
    nSrcs = len( srcs )
    dests = [ 0 ] * nDests
    # Break srcs down least-significant bit first, shifting down:
    for j in range( nDests - 1, -1, -1 ):
        # Put dests together most-significant first, shifting up:
        dest = 0
        for k in range( nSrcs ):
            dest = dest * 2 + srcs[ k ] % 2
            srcs[ k ] /= 2
        dests[ j ] = dest
    return dests

            
# Gray encoder and decoder from http://en.wikipedia.org/wiki/Gray_code :
#
def gray_encode( bn ):
    assert bn >= 0
    assert type( bn ) in [ int, long ]

    return bn ^ ( bn / 2 )

def gray_decode( n ):
    sh = 1
    while True:
        div = n >> sh
        n ^= div
        if div <= 1: return n

        sh <<= 1


## gray_encode_travel -- gray_encode given start and end using bit rotation.
#    Modified Gray code.  mask is 2**nbits - 1, the highest i value, so
#        gray_encode_travel( start, end, mask, 0 )    == start
#        gray_encode_travel( start, end, mask, mask ) == end
#        with a Gray-code-like walk in between.
#    This method takes the canonical Gray code, rotates the output word bits,
#    then xors ("^" in Python) with the start value.
#
def gray_encode_travel( start, end, mask, i ):
    travel_bit = start ^ end
    modulus = mask + 1          # == 2**nBits
    # travel_bit = 2**p, the bit we want to travel.
    # Canonical Gray code travels the top bit, 2**(nBits-1).
    # So we need to rotate by ( p - (nBits-1) ) == (p + 1) mod nBits.
    # We rotate by multiplying and dividing by powers of two:
    g = gray_encode( i ) * ( travel_bit * 2 )
    return ( ( g | ( g / modulus ) ) & mask ) ^ start

def gray_decode_travel( start, end, mask, g ):
    travel_bit = start ^ end
    modulus = mask + 1          # == 2**nBits
    rg = ( g ^ start ) * ( modulus / ( travel_bit * 2 ) )
    return gray_decode( ( rg | ( rg / modulus ) ) & mask )


## child_start_end( parent_start, parent_end, mask, i ) -- Get start & end for child.
#    i is the parent's step number, between 0 and mask.
#    Say that parent( i ) =
#           gray_encode_travel( parent_start, parent_end, mask, i ).
#    And child_start(i) and child_end(i) are what child_start_end()
#    should return -- the corners the child should travel between
#    while the parent is in this quadrant or child cube.
#      o  child_start( 0 ) == parent( 0 )       (start in a corner)
#      o  child_end( mask ) == parent( mask )   (end in a corner)
#      o  child_end(i) - child_start(i+1) == parent(i+1) - parent(i)
#         (when parent bit flips, same bit of child flips the opposite way)
#    Those constraints still leave choices when nD (# of bits in mask) > 2.
#    Here is how we resolve them when nD == 3 (mask == 111 binary),
#    for parent_start = 000 and parent_end = 100 (canonical Gray code):
#         i   parent(i)    child_
#         0     000        000   start(0)    = parent(0)
#                          001   end(0)                   = parent(1)
#                 ^ (flip)   v
#         1     001        000   start(1)    = parent(0)
#                          010   end(1)                   = parent(3)
#                ^          v
#         2     011        000   start(2)    = parent(0)
#                          010   end(2)                   = parent(3)
#                 v          ^
#         3     010        011   start(3)    = parent(2)
#                          111   end(3)                   = parent(5)
#               ^          v 
#         4     110        011   start(4)    = parent(2)
#                          111   end(4)                   = parent(5)
#                 ^          v
#         5     111        110   start(5)    = parent(4)
#                          100   end(5)                   = parent(7)
#                v          ^
#         6     101        110   start(6)    = parent(4)
#                          100   end(6)                   = parent(7)
#                 v          ^
#         7     100        101   start(7)    = parent(6)
#                          100   end(7)                   = parent(7)
#    This pattern relies on the fact that gray_encode_travel()
#    always flips the same bit on the first, third, fifth, ... and last flip.
#    The pattern works for any nD >= 1.
#
def child_start_end( parent_start, parent_end, mask, i ):
   start_i = max( 0,    ( i - 1 ) & ~1 )  # next lower even number, or 0
   end_i =   min( mask, ( i + 1 ) |  1 )  # next higher odd number, or mask
   child_start = gray_encode_travel( parent_start, parent_end, mask, start_i )
   child_end   = gray_encode_travel( parent_start, parent_end, mask, end_i )
   return child_start, child_end

def check_visited( visited, prefix, linear_size, nD ):
    if nD > 0:
        for i in range( linear_size ):
            check_visited( visited, prefix + [i], linear_size, nD - 1 )
    else:
        if not tuple( prefix ) in visited:
            print "missing", prefix

def tuple_print_width( n ):  # tuple with n 1-digit numbers and trailing sp
    if n == 0:  return 3   # ()_
    if n == 1:  return 5   # (1,)_  special case
    else:       return n * 3 + 1

def int_to_Hilbert_test( n, nD, doPrint=True ):
    tups_per_line = 2**( int( log( 80 / tuple_print_width( nD ), 2 ) ) )
    linear_size = int( ( n + .5 ) ** (1./nD) )
    isCube = linear_size ** nD == n
    if not isCube:
        print "(This is not a complete cube:)"
    visited = {}        
    for i in range( n ):
        pt = tuple( int_to_Hilbert( i, nD ) )
        if doPrint: print pt,
        visited[ pt ] = True      # Add pt to "visited" dictionary.
        j = Hilbert_to_int( pt )
        if j != i:
            print "BZZT, decodes to", j,

        if i > 0:  # Check that we have stepped one unit, along one dim:
            nDiffs = sum( [ pt[k] != prev_pt[k] for k in range( nD ) ] )
            if nDiffs != 1:
                print "BZZT, different along", nDiffs, "dimensions",
            maxDiff = max( [ abs(pt[k] - prev_pt[k]) for k in range( nD ) ] )
            if maxDiff != 1:
                print "BZZT, max difference is", maxDiff,

        prev_pt = pt
        if ( i + 1 ) % tups_per_line == 0:
            if doPrint: print

    if isCube:
        check_visited( visited, [], linear_size, nD )

maxh = Hilbert_to_int( [512,512,512] )
lines = file("500.sco").readlines()
for line in lines:
    line = line.strip()
    strs = line.split(" ")
    x,y,z = strs[3],strs[4],strs[5]
    h = Hilbert_to_int( [int(x),int(y),int(z)] )
    hn = (1.0*h) / maxh
    strs[0] = "i2"
    strs.append(str(h))
    strs.append(str(hn))
    print " ".join(strs)

    
