/* Hash algorithms
(C) 2016 Niall Douglas http://www.nedprod.com/
File Created: Aug 2016


Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/

#ifndef BOOSTLITE_ALGORITHM_HASH_HPP
#define BOOSTLITE_ALGORITHM_HASH_HPP

#include "../config.hpp"

BOOSTLITE_NAMESPACE_BEGIN

namespace algorithm
{
  namespace hash
  {
    //! \brief A STL compatible hash which passes through its input
    template <class T> struct passthru_hash
    {
      size_t operator()(T v) const { return static_cast<size_t>(v); }
    };

    //! \brief A STL compatible hash based on the high quality FNV1 hash algorithm
    template <class T> struct fnv1a_hash
    {
      size_t operator()(T v) const
      {
#if defined(__x86_64__) || defined(_M_X64) || defined(__aarch64__) || defined(__ia64__) || defined(_M_IA64) || defined(__ppc64__)
        static constexpr size_t basis = 14695981039346656037ULL, prime = 1099511628211ULL;
        static_assert(sizeof(size_t) == 8, "size_t is not 64 bit");
#else
        static constexpr size_t basis = 2166136261U, prime = 16777619U;
        static_assert(sizeof(size_t) == 4, "size_t is not 32 bit");
#endif
        const unsigned char *_v = (const unsigned char *) &v;
        size_t ret = basis;
        for(size_t n = 0; n < sizeof(T); n++)
        {
          ret ^= (size_t) _v[n];
          ret *= prime;
        }
        return ret;
      }
    };
  }
}

BOOSTLITE_NAMESPACE_END

#endif