/+  tester
=,  eyre
::
::::  %zuse additions
::
|%
::  +rev: reverses block order, accounting for leading zeroes
::
::    XX deduplicate with Mark's eth stuff
::
++  rev
  ::  boq: block size
  ::  len: size of dat, in boq
  ::  dat: data to reverse
  ::
  |=  [boq=bloq len=@ud dat=@]
  =+  (swp boq dat)
  (lsh boq (sub len (met boq dat)) -)
::  |base64: flexible base64 encoding for little-endian atoms
::
++  base64
  ::  pad: include padding when encoding, require when decoding
  ::  url: use url-safe characters '-' for '+' and '_' for '/'
  ::
  =+  [pad=& url=|]
  |%
  ::  +en:base64: encode +octs to base64 cord
  ::
  ++  en
    |=  inp=octs
    ^-  cord
    ::  dif: offset from 3-byte block
    ::
    =/  dif=@ud  (~(dif fo 3) 0 p.inp)
    ::  dap: reversed, 3-byte block-aligned input
    ::
    =/  dap=@ux  (lsh 3 dif (rev 3 inp))
    =/  cha
      ?:  url
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_'
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    %-  crip
    %-  flop
    %+  weld
      ?.(pad ~ (reap dif '='))
    %+  slag  dif
    |-  ^-  tape
    ?:  =(0x0 dap)  ~
    =/  d  (end 3 3 dap)
    :*  (cut 3 [(cut 0 [0 6] d) 1] cha)
        (cut 3 [(cut 0 [6 6] d) 1] cha)
        (cut 3 [(cut 0 [12 6] d) 1] cha)
        (cut 3 [(cut 0 [18 6] d) 1] cha)
        $(dap (rsh 3 3 dap))
    ==
  ::  +de:base64: decode base64 cord to (unit @)
  ::
  ++  de
    |=  a=cord
    ^-  (unit octs)
    (rush a parse)
  ::  +parse:base64: parse base64 cord to +octs
  ::
  ++  parse
    =<  ^-  $-(nail (like octs))
        %+  sear  reduce
        ;~  plug
          %-  plus  ;~  pose
            (cook |=(a=@ (sub a 'A')) (shim 'A' 'Z'))
            (cook |=(a=@ (sub a 'G')) (shim 'a' 'z'))
            (cook |=(a=@ (add a 4)) (shim '0' '9'))
            (cold 62 (just ?:(url '-' '+')))
            (cold 63 (just ?:(url '_' '/')))
          ==
          (stun 0^2 (cold %0 tis))
        ==
    |%
    ::  +reduce:parse:base64: reduce, measure, and swap base64 digits
    ::
    ++  reduce
      |=  [dat=(list @) dap=(list @)]
      ^-  (unit octs)
      =/  lat  (lent dat)
      =/  lap  (lent dap)
      =/  dif  (~(dif fo 4) 0 lat)
      ?:  &(pad !=(dif lap))
        ::  padding required and incorrect
        ~&(%base-64-padding-err-one ~)
      ?:  &(!pad !=(0 lap))
        ::  padding not required but present
        ~&(%base-64-padding-err-two ~)
      =/  len  (sub (mul 3 (div (add lat dif) 4)) dif)
      :+  ~  len
      %+  swp  3
      ::  %+  base  64
      %+  roll
        (weld dat (reap dif 0))
      |=([p=@ q=@] (add p (mul 64 q)))
    --
  --
::  +en-base64url: url-safe base64 encoding, without padding
::
++  en-base64url
  ~(en base64 | &)
::  +de-base64url: url-safe base64 decoding, without padding
::
++  de-base64url
  ~(de base64 | &)
::  |octn: encode/decode unsigned atoms as big-endian octet stream
::
++  octn
  |%
  ++  en  |=(a=@u `octs`[(met 3 a) (swp 3 a)])
  ++  de  |=(a=octs `@u`(rev 3 p.a q.a))
  --
::
::::  %/lib/pkcs
::
::  |asn1: small selection of types and constants for ASN.1
::
::    A minimal representation of some basic ASN.1 types,
::    created to support PKCS keys, digests, and cert requests.
::
++  asn1
  |%
  ::  +bespoke:asn1: context-specific, generic ASN.1 tag type
  ::
  ::    Note that *explicit* implies *constructed* (ie, bit 5 is set in DER).
  ::
  +=  bespoke
    ::  imp: & is implicit, | is explicit
    ::  tag: 5 bits for the custom tag number
    ::
    [imp=? tag=@ud]
  ::  +spec:asn1: minimal representations of basic ASN.1 types
  ::
  +=  spec
    $%  ::  %int: arbitrary-sized, unsigned integers
        ::
        ::    Unsigned integers, represented as having a positive sign.
        ::    Negative integers would be two's complement in DER,
        ::    but we don't need them.
        ::
        [%int int=@u]
        ::  %bit: very minimal support for bit strings
        ::
        ::    Specifically, values must already be padded and byte-aligned.
        ::    len: bitwidth
        ::    bit: data
        ::
        [%bit len=@ud bit=@ux]
        ::  %oct: octets in little-endian byte order
        ::
        ::    len: bytewidth
        ::    bit: data
        ::
        [%oct len=@ud oct=@ux]
        ::  %nul: fully supported!
        ::
        [%nul ~]
        ::  %obj: object identifiers, pre-packed
        ::
        ::    Object identifiers are technically a sequence of integers,
        ::    represented here in their already-encoded form.
        ::
        [%obj obj=@ux]
        ::  %seq: a list of specs
        ::
        [%seq seq=(list spec)]
        ::  %set: a logical set of specs
        ::
        ::    Implemented here as a list for the sake of simplicity.
        ::    must be already deduplicated and sorted!
        ::
        [%set set=(list spec)]
        ::  %con: context-specific
        ::
        ::    General support for context-specific tags.
        ::    bes: custom tag number, implicit or explicit
        ::    con: already-encoded bytes
        ::
        [%con bes=bespoke con=(list @D)]
    ==
  ::  |obj:asn1: constant object ids, pre-encoded
  ::
  ++  obj
    |%                                                ::    rfc4055
    ++  sha-256      0x1.0204.0365.0148.8660          ::  2.16.840.1.101.3.4.2.1
    ++  rsa          0x1.0101.0df7.8648.862a          ::  1.2.840.113549.1.1.1
    ++  rsa-sha-256  0xb.0101.0df7.8648.862a          ::  1.2.840.113549.1.1.11
                                                      ::    rfc2985
    ++  csr-ext      0xe.0901.0df7.8648.862a          ::  1.2.840.113549.1.9.14
                                                      ::    rfc3280
    ++  sub-alt      0x11.1d55                        ::  2.5.29.17
    --
  --
::  |der: distinguished encoding rules for ASN.1
::
::    DER is a tag-length-value binary encoding for ASN.1, designed
::    so that there is only one (distinguished) valid encoding for an
::    instance of a type.
::
++  der
  |%
  ::  +en:der: encode +spec:asn1 to +octs (kindof)
  ::
  ++  en
    =<  |=  a=spec:asn1
        ^-  [len=@ud dat=@ux]
        =/  b  ~(ren raw a)
        [(lent b) (rep 3 b)]
    |%
    ::  +raw:en:der: door for encoding +spec:asn1 to list of bytes
    ::
    ++  raw
      |_  pec=spec:asn1
      ::  +ren:raw:en:der: render +spec:asn1 to tag-length-value bytes
      ::
      ++  ren
        ^-  (list @D)
        =/  a  lem
        [tag (weld (len a) a)]
      ::  +tag:raw:en:der: tag byte
      ::
      ++  tag
        ^-  @D
        ?-  pec
          [%int *]   2
          [%bit *]   3
          [%oct *]   4
          [%nul *]   5
          [%obj *]   6
          [%seq *]  48              :: constructed: (con 0x20 16)
          [%set *]  49              :: constructed: (con 0x20 17)
          [%con *]  ;:  con
                      0x80                    :: context-specifc
                      ?:(imp.bes.pec 0 0x20)  :: implicit?
                      (dis 0x1f tag.bes.pec)  :: 5 bits of custom tag
                    ==
        ==
      ::  +lem:raw:en:der: element bytes
      ::
      ++  lem
        ^-  (list @D)
        ?-  pec
          ::  unsigned only, interpreted as positive-signed and
          ::  rendered in big-endian byte order. negative-signed would
          ::  be two's complement
          ::
          [%int *]  =/  a  (flop (rip 3 int.pec))
                    ?~  a  [0 ~]
                    ?:((lte i.a 127) a [0 a])
          ::  padded to byte-width, must be already byte-aligned
          ::
          [%bit *]  =/  a  (rip 3 bit.pec)
                    =/  b  ~|  %der-invalid-bit
                        ?.  =(0 (mod len.pec 8))
                          ~|(%der-invalid-bit-alignment !!)
                        (sub (div len.pec 8) (lent a))
                    [0 (weld a (reap b 0))]
          ::  padded to byte-width
          ::
          [%oct *]  =/  a  (rip 3 oct.pec)
                    =/  b  ~|  %der-invalid-oct
                        (sub len.pec (lent a))
                    (weld a (reap b 0))
          ::
          [%nul *]  ~
          [%obj *]  (rip 3 obj.pec)
          ::
          [%seq *]  %-  zing
                    |-  ^-  (list (list @))
                    ?~  seq.pec  ~
                    :-  ren(pec i.seq.pec)
                    $(seq.pec t.seq.pec)
          ::  presumed to be already deduplicated and sorted
          ::
          [%set *]  %-  zing
                    |-  ^-  (list (list @))
                    ?~  set.pec  ~
                    :-  ren(pec i.set.pec)
                    $(set.pec t.set.pec)
          ::  already constructed
          ::
          [%con *]  con.pec
        ==
      ::  +len:raw:en:der: length bytes
      ::
      ++  len
        |=  a=(list @D)
        ^-  (list @D)
        =/  b  (lent a)
        ?:  (lte b 127)
          [b ~]                :: note: big-endian
        [(con 0x80 (met 3 b)) (flop (rip 3 b))]
      --
    --
  ::  +de:der: decode atom to +spec:asn1
  ::
  ++  de
    |=  [len=@ud dat=@ux]
    ^-  (unit spec:asn1)
    :: XX refactor into +parse
    =/  a  (rip 3 dat)
    =/  b  ~|  %der-invalid-len
        (sub len (lent a))
    (rust `(list @D)`(weld a (reap b 0)) parse)
  ::  +parse:der: DER parser combinator
  ::
  ++  parse
    =<  ^-  $-(nail (like spec:asn1))
        ;~  pose
          (stag %int (bass 256 (sear int ;~(pfix (tag 2) till))))
          (stag %bit (sear bit (boss 256 ;~(pfix (tag 3) till))))
          (stag %oct (boss 256 ;~(pfix (tag 4) till)))
          (stag %nul (cold ~ ;~(plug (tag 5) (tag 0))))
          (stag %obj (^boss 256 ;~(pfix (tag 6) till)))
          (stag %seq (sear recur ;~(pfix (tag 48) till)))
          (stag %set (sear recur ;~(pfix (tag 49) till)))
          (stag %con ;~(plug (sear context next) till))
        ==
    |%
    ::  +tag:parse:der: parse tag byte
    ::
    ++  tag
      |=(a=@D (just a))
    ::  +int:parse:der: sear unsigned big-endian bytes
    ::
    ++  int
      |=  a=(list @D)
      ^-  (unit (list @D))
      ?~  a  ~
      ?:  ?=([@ ~] a)  `a
      ?.  =(0 i.a)  `a
      ?.((gth i.t.a 127) ~ `t.a)
    ::  +bit:parse:der: convert bytewidth to bitwidth
    ::
    ++  bit
      |=  [len=@ud dat=@ux]
      ^-  (unit [len=@ud dat=@ux])
      ?.  =(0 (end 3 1 dat))  ~
      :+  ~
        (mul 8 (dec len))
      (rsh 3 1 dat)
    ::  +recur:parse:der: parse bytes for a list of +spec:asn1
    ::
    ++  recur
      |=(a=(list @) (rust a (star parse)))
    ::  +context:parse:der: decode context-specific tag byte
    ::
    ++  context
      |=  a=@D
      ^-  (unit bespoke:asn1)
      ?.  =(1 (cut 0 [7 1] a))  ~
      :+  ~
        =(1 (cut 0 [5 1] a))
      (dis 0x1f a)
    ::  +boss:parse:der: shadowed to count as well
    ::
    ::    Use for parsing +octs more broadly?
    ::
    ++  boss
      |*  [wuc=@ tyd=rule]
      %+  cook
        |=  waq=(list @)
        :-  (lent waq)
        (reel waq |=([p=@ q=@] (add p (mul wuc q))))
      tyd
    ::  +till:parse:der: parser combinator for len-prefixed bytes
    ::
    ::  advance until
    ::
    ++  till
      |=  tub/nail
      ^-  (like (list @D))
      ?~  q.tub
        (fail tub)
      ::  fuz: first byte - length, or length of the length
      ::
      =*  fuz  i.q.tub
      ::  nex: offset of value bytes from fuz
      ::  len: length of value bytes
      ::
      =+  ^-  [nex=@ len=@]
        ::  faz: meaningful bits in fuz
        ::
        =/  faz  (end 0 7 fuz)
        ?:  =(0 (cut 0 [7 1] fuz))
          [0 faz]
        [faz (rep 3 (flop (scag faz t.q.tub)))]
      ?:  ?&  !=(0 nex)
              !=(nex (met 3 len))
          ==
        (fail tub)
      ::  zuf: value bytes
      ::
      =/  zuf  (swag [nex len] t.q.tub)
      ?.  =(len (lent zuf))
        (fail tub)
      ::  zaf:  product nail
      ::
      =/  zaf  [p.p.tub (add +(nex) q.p.tub)]
      [zaf `[zuf zaf (slag (add nex len) t.q.tub)]]
    --
  --
::  |rsa: primitive, textbook RSA
::
::    Unpadded, unsafe, unsuitable for encryption!
::
++  rsa
  |%
  ::  +key:rsa: rsa public or private key
  ::
  +=  key
    $:  ::  pub:  public parameters (n=modulus, e=pub-exponent)
        ::
        pub=[n=@ux e=@ux]
        ::  sek:  secret parameters (d=private-exponent, p/q=primes)
        ::
        sek=(unit [d=@ux p=@ux q=@ux])
    ==
  ::  +ramp: make rabin-miller probabilistic prime
  ::
  ::    XX replace +ramp:number?
  ::    a: bitwidth
  ::    b: snags (XX small primes to check divisibility?)
  ::    c: entropy
  ::
  ++  ramp
    |=  [a=@ b=(list @) c=@]
    =.  c  (shas %ramp c)
    :: XX what is this value?
    ::
    =|  d=@
    |-  ^-  @ux
    :: XX what is this condition?
    ::
    ?:  =((mul 100 a) d)
      ~|(%ar-ramp !!)
    :: e: prime candidate
    ::
    ::   Sets low bit, as prime must be odd.
    ::   Sets high bit, as +raw:og only gives up to :a bits.
    ::
    =/  e  :(con 1 (lsh 0 (dec a) 1) (~(raw og c) a))
    :: XX what algorithm is this modular remainder check?
    ::
    ?:  ?&  (levy b |=(f/@ !=(1 (mod e f))))
            (pram:number e)
        ==
      e
    $(c +(c), d (shax d))
  ::  +elcm:rsa: carmichael totient
  ::
  ++  elcm
    |=  [a=@ b=@]
    (div (mul a b) d:(egcd a b))
  ::  +new-key:rsa: write somethingXXX
  ::
  ++  new-key
    =/  e  `@ux`65.537
    |=  [wid=@ eny=@]
    ^-  key
    =/  diw  (rsh 0 1 wid)
    =/  p=@ux  (ramp diw [3 5 ~] eny)
    =/  q=@ux  (ramp diw [3 5 ~] +(eny))
    =/  n=@ux  (mul p q)
    =/  d=@ux  (~(inv fo (elcm (dec p) (dec q))) e)
    [[n e] `[d p q]]
  ::  +en:rsa: primitive RSA encryption
  ::
  ::    ciphertext = message^e (mod n)
  ::
  ++  en
    |=  [m=@ k=key]
    ~|  %rsa-len
    ?>  (lte (met 0 m) (met 0 n.pub.k))
    (~(exp fo n.pub.k) e.pub.k m)
  ::  +de:rsa: primitive RSA decryption
  ::
  ::    message = ciphertext^d (mod e)
  ::
  ++  de
    |=  [m=@ k=key]
    :: XX assert rsa-len here too?
    ~|  %rsa-need-ring
    ?>  ?=(^ sek.k)
    =/  fu  (fu:number p.u.sek.k q.u.sek.k)
    (out.fu (exp.fu d.u.sek.k (sit.fu m)))
  --
::  +rs256: RSA signatures over a sha-256 digest
::
++  rs256
  |_  k=key:rsa
  ::  +emsa:rs256: message digest
  ::
  ::    Padded, DER encoded sha-256 hash (EMSA-PKCS1-v1_5).
  ::
  ++  emsa
    |=  m=@
    =/  emlen  (met 3 n.pub.k)
    =/  pec=spec:asn1
      :~  %seq
          [%seq [%obj sha-256:obj:asn1] [%nul ~] ~]
          [%oct 32 (shax m)]
      ==
    ::  note: this asn.1 digest is rendered raw here, as we require
    ::  big-endian bytes, and the product of +en:der is little-endian
    ::
    =/  t=(list @D)  ~(ren raw:en:der pec)
    =/  tlen=@ud  (lent t)
    ?:  (lth emlen (add 11 tlen))
      ~|(%emsa-too-short !!)
    =/  ps=(list @D)
      (reap (sub emlen (add 3 tlen)) 0xff)
    (rep 3 (flop (weld [0x0 0x1 ps] [0x0 t])))
  ::  +sign:rs256: sign message
  ::
  ::    An RSA signature is the primitive decryption of the message hash.
  ::
  ++  sign
    |=(m=@ (de:rsa (emsa m) k))
  ::  +verify:rs256: verify signature
  ::
  ::    RSA signature verification confirms that the primitive encryption
  ::    of the signature matches the message hash.
  ::
  ++  verify
    |=  [s=@ m=@]
    =((emsa m) (en:rsa s k))
  --
::  |pem: generic PEM implementation (rfc7468)
::
::    PEM is the base64 encoding of DER encoded data, with BEGIN and
::    END labels indicating some type.
::
++  pem
  |%
  ::  +en:pem: PEM encode
  ::
  ++  en
    |=  [lab=@t len=@ud der=@ux]
    ^-  wain
    :: XX validate label?
    :-  (rap 3 ['-----BEGIN ' lab '-----' ~])
    =/  a  (en:base64 len `@`der)
    |-  ^-  wain
    ?~  a
      [(rap 3 ['-----END ' lab '-----' ~]) ~]
    [(end 3 64 a) $(a (rsh 3 64 a))]
  ::  +de:pem: PEM decode
  ::
  ++  de
    |=  [lab=@t mep=wain]
    ^-  (unit [len=@ud der=@ux])
    =/  a  (sub (lent mep) 2)
    ?~  mep  ~
    :: XX validate label?
    ?.  =((rap 3 ['-----BEGIN ' lab '-----' ~]) i.mep)  ~
    ?.  =((rap 3 ['-----END ' lab '-----' ~]) (snag a t.mep))  ~
    ^-  (unit [@ @])
    (de:base64 (rap 3 (scag a t.mep)))
  --
::  |pkcs1: RSA asymmetric cryptography (rfc3447)
::
++  pkcs1
  |%
  ::  |spec:pkcs1: ASN.1 specs for RSA keys
  ::
  ++  spec
    |%
    ::  |en:spec:pkcs1: ASN.1 encoding for RSA keys
    ::
    ++  en
      |%
      ::  +pass:en:spec:pkcs1: encode public key to ASN.1
      ::
      ++  pass
        |=  k=key:rsa
        ^-  spec:asn1
        [%seq [%int n.pub.k] [%int e.pub.k] ~]
      ::  +ring:en:spec:pkcs1: encode private key to ASN.1
      ::
      ++  ring
        |=  k=key:rsa
        ^-  spec:asn1
        ~|  %rsa-need-ring
        ?>  ?=(^ sek.k)
        :~  %seq
            [%int 0]
            [%int n.pub.k]
            [%int e.pub.k]
            [%int d.u.sek.k]
            [%int p.u.sek.k]
            [%int q.u.sek.k]
            [%int (mod d.u.sek.k (dec p.u.sek.k))]
            [%int (mod d.u.sek.k (dec q.u.sek.k))]
            [%int (~(inv fo p.u.sek.k) q.u.sek.k)]
        ==
      --
    ::  |de:spec:pkcs1: ASN.1 decoding for RSA keys
    ::
    ++  de
      |%
      ::  +pass:de:spec:pkcs1: decode ASN.1 public key
      ::
      ++  pass
        |=  a=spec:asn1
        ^-  (unit key:rsa)
        ?.  ?=([%seq [%int *] [%int *] ~] a)
          ~
        =*  n  int.i.seq.a
        =*  e  int.i.t.seq.a
        `[[n e] ~]
      ::  +ring:de:spec:pkcs1: decode ASN.1 private key
      ::
      ++  ring
        |=  a=spec:asn1
        ^-  (unit key:rsa)
        ?.  ?=([%seq *] a)  ~
        ?.  ?=  $:  [%int %0]
                    [%int *]
                    [%int *]
                    [%int *]
                    [%int *]
                    [%int *]
                    *
                ==
            seq.a
          ~
        =*  n  int.i.t.seq.a
        =*  e  int.i.t.t.seq.a
        =*  d  int.i.t.t.t.seq.a
        =*  p  int.i.t.t.t.t.seq.a
        =*  q  int.i.t.t.t.t.t.seq.a
        `[[n e] `[d p q]]
      --
    --
  ::  |der:pkcs1: DER encoding for RSA keys
  ::
  ::    En(coding) and de(coding) for public (pass) and private (ring) keys.
  ::
  ++  der
    |%
    ++  en
      |%
      ++  pass  |=(k=key:rsa (en:^der (pass:en:spec k)))
      ++  ring  |=(k=key:rsa (en:^der (ring:en:spec k)))
      --
    ++  de
      |%
      ++  pass  |=([len=@ud dat=@ux] `(unit key:rsa)`(biff (de:^der len dat) pass:de:spec))
      ++  ring  |=([len=@ud dat=@ux] `(unit key:rsa)`(biff (de:^der len dat) ring:de:spec))
      --
    --
  ::  |pem:pkcs1: PEM encoding for RSA keys
  ::
  ::    En(coding) and de(coding) for public (pass) and private (ring) keys.
  ::
  ++  pem
    |%
    ++  en
      |%
      ++  pass  |=(k=key:rsa (en:^pem 'RSA PUBLIC KEY' (pass:en:der k)))
      ++  ring  |=(k=key:rsa (en:^pem 'RSA PRIVATE KEY' (ring:en:der k)))
      --
    ++  de
      |%
      ++  pass  |=(mep=wain (biff (de:^pem 'RSA PUBLIC KEY' mep) pass:de:der))
      ++  ring  |=(mep=wain (biff (de:^pem 'RSA PRIVATE KEY' mep) ring:de:der))
      --
    --
  --
::  |pkcs8: asymmetric cryptography (rfc5208, rfc5958)
::
::    RSA-only for now.
::
++  pkcs8
  |%
  ::  |spec:pkcs8: ASN.1 specs for asymmetric keys
  ::
  ++  spec
    |%
    ++  en
      |%
      ::  +pass:spec:pkcs8: public key ASN.1
      ::
      ::    Technically not part of pkcs8, but standardized later in
      ::    the superseding RFC. Included here for symmetry.
      ::
      ++  pass
        |=  k=key:rsa
        ^-  spec:asn1
        :~  %seq
            [%seq [[%obj rsa:obj:asn1] [%nul ~] ~]]
            =/  a=[len=@ud dat=@ux]
              (pass:en:der:pkcs1 k)
            [%bit (mul 8 len.a) dat.a]
        ==
      ::  +ring:spec:pkcs8: private key ASN.1
      ::
      ++  ring
        |=  k=key:rsa
        ^-  spec:asn1
        :~  %seq
            [%int 0]
            [%seq [[%obj rsa:obj:asn1] [%nul ~] ~]]
            [%oct (ring:en:der:pkcs1 k)]
        ==
      --
    ::  |de:spec:pkcs8: ASN.1 decoding for asymmetric keys
    ::
    ++  de
      |%
      ::  +pass:de:spec:pkcs8: decode public key ASN.1
      ::
      ++  pass
        |=  a=spec:asn1
        ^-  (unit key:rsa)
        ?.  ?=([%seq [%seq *] [%bit *] ~] a)
          ~
        ?.  ?&  ?=([[%obj *] [%nul ~] ~] seq.i.seq.a)
                =(rsa:obj:asn1 obj.i.seq.i.seq.a)
            ==
          ~
        (pass:de:der:pkcs1 (div len.i.t.seq.a 8) bit.i.t.seq.a)
      ::  +ring:de:spec:pkcs8: decode private key ASN.1
      ::
      ++  ring
        |=  a=spec:asn1
        ^-  (unit key:rsa)
        ?.  ?=([%seq [%int %0] [%seq *] [%oct *] ~] a)
          ~
        ?.  ?&  ?=([[%obj *] [%nul ~] ~] seq.i.t.seq.a)
                =(rsa:obj:asn1 obj.i.seq.i.t.seq.a)
            ==
          ~
        (ring:de:der:pkcs1 [len oct]:i.t.t.seq.a)
      --
    --
  ::  |der:pkcs8: DER encoding for asymmetric keys
  ::
  ::    En(coding) and de(coding) for public (pass) and private (ring) keys.
  ::    RSA-only for now.
  ::
  ++  der
    |%
    ++  en
      |%
      ++  pass  |=(k=key:rsa `[len=@ud dat=@ux]`(en:^der (pass:en:spec k)))
      ++  ring  |=(k=key:rsa `[len=@ud dat=@ux]`(en:^der (ring:en:spec k)))
      --
    ++  de
      |%
      ++  pass  |=([len=@ud dat=@ux] `(unit key:rsa)`(biff (de:^der len dat) pass:de:spec))
      ++  ring  |=([len=@ud dat=@ux] `(unit key:rsa)`(biff (de:^der len dat) ring:de:spec))
      --
    --
  ::  |pem:pkcs8: PEM encoding for asymmetric keys
  ::
  ::    En(coding) and de(coding) for public (pass) and private (ring) keys.
  ::    RSA-only for now.
  ::
  ++  pem
    |%
    ++  en
      |%
      ++  pass  |=(k=key:rsa (en:^pem 'PUBLIC KEY' (pass:en:der k)))
      ++  ring  |=(k=key:rsa (en:^pem 'PRIVATE KEY' (ring:en:der k)))
      --
    ++  de
      |%
      ++  pass  |=(mep=wain (biff (de:^pem 'PUBLIC KEY' mep) pass:de:der))
      ++  ring  |=(mep=wain (biff (de:^pem 'PRIVATE KEY' mep) ring:de:der))
      --
    --
  --
::  |pkcs10: certificate signing requests (rfc2986)
::
::    Only implemented for RSA keys with subject-alternate names.
::
++  pkcs10
  =>  |%
      ::  +csr:pkcs10: certificate request
      ::
      +=  csr  [key=key:rsa hot=(list (list @t))]
      --
  |%
  ::  |spec:pkcs10: ASN.1 specs for certificate signing requests
  ::
  ++  spec
    |%
    ::  +en:spec:pkcs10: ASN.1 encoding for certificate signing requests
    ::
    ++  en
      |=  csr
      ^-  spec:asn1
      |^  =/  dat=spec:asn1  (info key hot)
          :~  %seq
              dat
              [%seq [[%obj rsa-sha-256:obj:asn1] [%nul ~] ~]]
              :: big-endian signature bits
              ::
              ::   the signature bitwidth is definitionally the key length
              ::
              :+  %bit
                (met 0 n.pub.key)
              (swp 3 (~(sign rs256 key) +:(en:^der dat)))
          ==
      ::  +info:en:spec:pkcs10: certificate request info
      ::
      ++  info
        |=  csr
        ^-  spec:asn1
        :~  %seq
            [%int 0]
            [%seq ~]
            (pass:en:spec:pkcs8 key)
            :: explicit, context-specific tag #0 (extensions)
            ::
            :+  %con
              `bespoke:asn1`[| 0]
            %~  ren
              raw:en:^der
            :~  %seq
                [%obj csr-ext:obj:asn1]
                :~  %set
                    :~  %seq
                        :~  %seq
                            [%obj sub-alt:obj:asn1]
                            [%oct (en:^der (san hot))]
        ==  ==  ==  ==  ==
      ::  +san:en:spec:pkcs10: subject-alternate-names
      ::
      ++  san
        |=  hot=(list (list @t))
        ^-  spec:asn1
        :-  %seq
        %+  turn  hot
        :: implicit, context-specific tag #2 (IA5String)
        :: XX sanitize string?
        |=(h=(list @t) [%con `bespoke:asn1`[& 2] (rip 3 (join '.' h))])
      --
    ::  |de:spec:pkcs10: ASN.1 decoding for certificate signing requests
    ++  de  !!
    --
  ::  |der:pkcs10: DER encoding for certificate signing requests
  ::
  ++  der
    |%
    ++  en  |=(a=csr `[len=@ud der=@ux]`(en:^der (en:spec a)))
    ++  de  !! ::|=(a=@ `(unit csr)`(biff (de:^der a) de:spec))
    --
  ::  |pem:pkcs10: PEM encoding for certificate signing requests
  ::
  ++  pem
    |%
    ++  en  |=(a=csr (en:^pem 'CERTIFICATE REQUEST' (en:der a)))
    ++  de  !! ::|=(mep=wain (biff (de:^pem 'CERTIFICATE REQUEST' mep) de:der))
    --
  --
::  +en-json-sort: json encoding with sorted object keys
::
::    to be included in %zuse, with sorting optional?
::
++  en-json-sort                                 ::  XX rename
  |^  |=([sor=$-(^ ?) val=json] (apex val sor ""))
  ::                                                  ::  ++apex:en-json:html
  ++  apex
    =,  en-json:html
    |=  {val/json sor/$-(^ ?) rez/tape}
    ^-  tape
    ?~  val  (weld "null" rez)
    ?-    -.val
        $a
      :-  '['
      =.  rez  [']' rez]
      !.
      ?~  p.val  rez
      |-
      ?~  t.p.val  ^$(val i.p.val)
      ^$(val i.p.val, rez [',' $(p.val t.p.val)])
   ::
        $b  (weld ?:(p.val "true" "false") rez)
        $n  (weld (trip p.val) rez)
        $s
      :-  '"'
      =.  rez  ['"' rez]
      =+  viz=(trip p.val)
      !.
      |-  ^-  tape
      ?~  viz  rez
      =+  hed=(jesc i.viz)
      ?:  ?=({@ $~} hed)
        [i.hed $(viz t.viz)]
      (weld hed $(viz t.viz))
   ::
        $o
      :-  '{'
      =.  rez  ['}' rez]
      =/  viz
        %+  sort  ~(tap by p.val)
        |=((pair) (sor (head p) (head q)))
      ?~  viz  rez
      !.
      |-  ^+  rez
      ?~  t.viz  ^$(val [%s p.i.viz], rez [':' ^$(val q.i.viz)])
      =.  rez  [',' $(viz t.viz)]
      ^$(val [%s p.i.viz], rez [':' ^$(val q.i.viz)])
    ==
  --
::
::  %/lib/jose
::
::  |jwk: json representations of cryptographic keys (rfc7517)
::
::    Url-safe base64 encoding of key parameters in big-endian byte order.
::    RSA-only for now
::
++  jwk
  |%
  ::  |en:jwk: encoding of json cryptographic keys
  ::
  ++  en
    =>  |%
        ::  +numb:en:jwk: base64-url encode big-endian number
        ::
        ++  numb  (corl en-base64url en:octn)
        --
    |%
    ::  +pass:en:jwk: json encode public key
    ::
    ++  pass
      |=  k=key:rsa
      ^-  json
      [%o (my kty+s+'RSA' n+s+(numb n.pub.k) e+s+(numb e.pub.k) ~)]
    ::  +ring:en:jwk: json encode private key
    ::
    ++  ring
      |=  k=key:rsa
      ^-  json
      ~|  %rsa-need-ring
      ?>  ?=(^ sek.k)
      :-  %o  %-  my  :~
        kty+s+'RSA'
        n+s+(numb n.pub.k)
        e+s+(numb e.pub.k)
        d+s+(numb d.u.sek.k)
        p+s+(numb p.u.sek.k)
        q+s+(numb q.u.sek.k)
      ==
    --
  ::  |de:jwk: decoding of json cryptographic keys
  ::
  ++  de
    =,  dejs-soft:format
    =>  |%
        ::  +numb:de:jwk: parse base64-url big-endian number
        ::
        ++  numb  (cu (cork de-base64url (lift de:octn)) so)
        --
    |%
    ::  +pass:de:jwk: decode json public key
    ::
    ++  pass
      %+  ci
        =/  a  (unit @ux)
        |=  [kty=@t n=a e=a]
        ^-  (unit key:rsa)
        =/  pub  (both n e)
        ?~(pub ~ `[u.pub ~])
      (ot kty+(su (jest 'RSA')) n+numb e+numb ~)
    ::  +ring:de:jwk: decode json private key
    ::
    ++  ring
      %+  ci
        =/  a  (unit @ux)
        |=  [kty=@t n=a e=a d=a p=a q=a]
        ^-  (unit key:rsa)
        =/  pub  (both n e)
        =/  sek  :(both d p q)
        ?:(|(?=(~ pub) ?=(~ sek)) ~ `[u.pub sek])
      (ot kty+(su (jest 'RSA')) n+numb e+numb d+numb p+numb q+numb ~)
    --
  ::  |thumb:jwk: "thumbprint" json-encoded key (rfc7638)
  ::
  ++  thumb
    |%
    ::  +pass:thumb:jwk: thumbprint json-encoded public key
    ::
    ++  pass
      |=  k=key:rsa
      (en-base64url 32 (shax (crip (en-json-sort aor (pass:en k)))))
    ::  +ring:thumb:jwk: thumbprint json-encoded private key
    ::
    ++  ring  !!
    --
  --
::  |jws: json web signatures (rfc7515)
::
::    Note: flattened signature form only.
::
++  jws
  |%
  ::  +sign:jws: sign json value
  ::
  ++  sign
    |=  [k=key:rsa pro=json lod=json]
    |^  ^-  json
        =.  pro  header
        =/  protect=cord  (encode pro)
        =/  payload=cord  (encode lod)
        :-  %o  %-  my  :~
          protected+s+protect
          payload+s+payload
          signature+s+(sign protect payload)
        ==
    ::  +header:sign:jws: set signature algorithm in header
    ::
    ++  header
      ?>  ?=([%o *] pro)
      ^-  json
      [%o (~(put by p.pro) %alg s+'RS256')]
    ::  +encode:sign:jws: encode json for signing
    ::
    ::    Alphabetically sort object keys, url-safe base64 encode
    ::    the serialized json.
    ::
    ++  encode
      |=  jon=json
      %-  en-base64url
      %-  as-octt:mimes:html
      (en-json-sort aor jon)
    ::  +sign:sign:jws: compute signature
    ::
    ::    Url-safe base64 encode in big-endian byte order.
    ::
    ++  sign
      |=  [protect=cord payload=cord]
      =/  sig=@ud  (~(sign rs256 k) (rap 3 ~[protect '.' payload]))
      =/  len=@ud  (met 3 n.pub.k)
      (en-base64url len (rev 3 len sig))
    --
  ::  +verify:jws: verify signature
  ::
  ++  verify  !!
  --
::  +eor: explicit sort order comparator
::
::    Lookup :a and :b in :lit, and pass their indices to :com.
::
++  eor
  |=  [com=$-([@ @] ?) lit=(list)]
  |=  [a=* b=*]
  ^-  ?
  (fall (bind (both (find ~[a] lit) (find ~[b] lit)) com) |)
::  +join: join list of cords with separator
::
++  join
  |=  [sep=@t hot=(list @t)]
  ^-  @t
  =|  out=(list @t)
  ?>  ?=(^ hot)
  |-  ^-  @t
  ?~  t.hot
    (rap 3 [i.hot out])
  $(out [sep i.hot out], hot t.hot)
:: |grab: acme api response json reparsers
::
++  grab
  =,  dejs:format
  |%
  :: +json-purl: parse url
  ::
  ++  json-purl  (su auri:de-purl:html)
  :: +directory: parse ACME service directory
  ::
  ++  directory
    %-  ot
    :~  ['newAccount' json-purl]
        ['newNonce' json-purl]
        ['newOrder' json-purl]
        ['revokeCert' json-purl]
        ['keyChange' json-purl]
    ==
  :: +acct: parse ACME service account
  ::
  ++  acct
    %-  ot
    :~  ['id' no]
        ['createdAt' so] :: XX (su iso-8601)
        ['status' so]
        :: ignore key, contact, initialIp
    ==
  :: +order: parse certificate order
  ::
  ++  order
    %-  ot
    :~  ['authorizations' (ar json-purl)]
        ['finalize' json-purl]
        ['expires' so] :: XX (su iso-8601)
        ['status' so]
    ==
  :: +finalizing-order: parse order in a finalizing state
  ::
  ::   XX remove once +order has optional keys
  ::
  ++  finalizing-order
    %-  ot
    :~  ['expires' so] :: XX (su iso-8601)
        ['status' so]
    ==
  :: +final-order: parse order in a finalized state
  ::
  ::   XX remove once +order has optional keys
  ::
  ++  final-order
    %-  ot
    :~  ['expires' so] :: XX (su iso-8601)
        ['status' so]
        ['certificate' json-purl]
    ==
  :: +auth: parse authorization
  ++  auth
    =>  |%
        :: +iden: parse dns identifier to +turf
        ::
        ++  iden
          |=  [typ=@t hot=host]
          ?>(&(?=(%dns typ) ?=([%& *] hot)) p.hot)
        :: +trial: transform parsed domain validation challenge
        ::
        ++  trial
          |=  a=(list [typ=@t sas=@t url=purl tok=@t])
          ^+  ?>(?=(^ a) i.a)
          =/  b
            (skim a |=([typ=@t *] ?=(%http-01 typ)))
          ?>(?=(^ b) i.b)
        --
    %-  ot
    :~  ['identifier' (cu iden (ot type+so value+(su thos:de-purl:html) ~))]
        ['status' so]
        ['expires' so] :: XX (su iso-8601)
        ['challenges' (cu trial (ar challenge))]
    ==
  :: +challenge: parse domain validation challenge
  ::
  ++  challenge
    %-  ot
    :~  ['type' so]
        ['status' so]
        ['url' json-purl]
        ['token' so]
    ==
  :: +error: parse ACME service error response
  ::
  ++  error
    %-  ot
    :~  ['type' so]
        ['detail' so]
    ==
  --
--
::
::::  acme state
::
|%
:: +move: output effect
::
+=  move  [bone card]
:: +card: output effect payload
::
+=  card
  $%  [%hiss wire [~ ~] %httr %hiss hiss:eyre]
      [%wait wire @da]
      [%well wire path (unit mime)]
      [%rule wire %cert (unit [wain wain])]
  ==
:: +nonce-next: next effect to emit upon receiving nonce
::
+=  nonce-next
  $?  %register
      %new-order
      %finalize-order
      %finalize-trial
  ==
:: +turf: a domain, TLD first
::
+=  turf  (list @t)
:: +acct: an ACME service account
::
+=  acct
  $:  :: key: account keypair
      ::
      key=key:rsa
      :: reg: account registration
      ::
      reg=(unit [wen=@t kid=@t])   :: XX wen=@da
  ==
:: +config: finalized configuration
::
+=  config
  $:  :: dom: domains
      ::
      dom=(set turf)
      :: key: certificate keypair
      ::
      key=key:rsa
      :: cer: signed certificate
      ::
      cer=wain
      :: exp: expiration date
      ::
      exp=@da
      :: dor: source ACME service order URL
      ::
      dor=purl
  ==
:: +trial: domain validation challenge
::
+=  trial
  $%  :: %http only for now
      $:  %http
          :: ego: ACME service challenge url
          ::
          ego=purl
          :: tok: challenge token
          ::
          tok=@t
          :: sas: challenge status
          ::
          sas=?(%recv %pend %auth)
  ==  ==
:: +auth: domain authorization
::
+=  auth
  $:  :: ego: ACME service authorization url
      ::
      ego=purl
      :: dom: domain under authorization
      ::
      dom=turf
      :: cal: domain validation challenge
      ::
      cal=trial
  ==
:: +order-auth: domain authorization state for order processing
::
+=  order-auth
  $:  :: pending: remote authorization urls
      ::
      pending=(list purl)
      :: active: authorization in progress
      ::
      active=(unit [idx=@ auth])
      :: done: finalized authorizations (XX or failed?)
      ::
      done=(list auth)
  ==
:: +order: ACME certificate order
::
+=  order
  $:  :: dom: domains
      ::
      dom=(set turf)
      :: sas: order state
      ::
      sas=$@(%wake [%rest wen=@da])
      :: exp: expiration date
      ::
      ::   XX @da once ISO-8601 parser
      ::
      exp=@t
      :: ego: ACME service order url
      ::
      ego=purl
      :: fin: ACME service order finalization url
      ::
      fin=purl
      :: key: certificate keypair
      ::
      key=key:rsa
      :: csr: DER-encoded PKCS10 certificate signing request
      ::
      csr=@ux
      :: aut: authorizations required by this order
      ::
      aut=order-auth
  ==
:: +history: archive of past ACME service interactions
::
+=  history
  $:  :: act: list of revoked account keypairs
      ::
      act=(list acct)
      :: fig: list of expired configurations
      ::
      fig=(list config)
      :: fal: list of failed order attempts
      ::
      fal=(list order)
  ==
:: +directory: ACME v2 service directory
::
+=  directory
  $:  :: reg: registration url (newAccount)
      ::
      reg=purl
      :: non: nonce creation url (newNonce)
      ::
      non=purl
      :: der: order creation url (newOrder)
      ::
      der=purl
      :: rev: certificate revocation url (revokeCert)
      ::
      rev=purl
      :: rek: account key revocation url (keyChange)
      ::
      rek=purl
  ==
:: +acme: complete app state
::
+=  acme
  $:  :: bas: ACME service root url
      ::
      bas=purl
      :: dir: ACME service directory
      ::
      dir=directory
      :: act: ACME service account
      ::
      act=acct
      :: liv: active, live configuration
      ::
      liv=(unit config)
      :: hit: ACME account history
      ::
      hit=history
      :: nonces: list of unused nonces
      ::
      nonces=(list @t)
      :: rod: active, in-progress order
      ::
      rod=(unit order)
      :: pen: pending domains for next order
      ::
      pen=(unit (set turf))
      :: cey: certificate key XX move?
      ::
      cey=key:rsa
  ==
--
::
::::  acme app
::
:: mov: list of outgoing moves for the current transaction
::
=|  mov=(list move)
::
|_  [bow=bowl:gall acme]
:: +this: self
::
::   XX Should be a +* core alias, see urbit/arvo#712
::
++  this  .
:: +emit: emit a move
::
++  emit
  |=  car=card
  ~&  [%emit car]
  this(mov [[ost.bow car] mov])
:: +abet: finalize transaction
::
++  abet
  ^-  (quip move _this)
  [(flop mov) this(mov ~)]
:: +request: generic http request
::
++  request
  |=  [wir=wire req=hiss]
  ^-  card
  [%hiss wir [~ ~] %httr %hiss req]
:: +signed-request: JWS JSON POST
::
++  signed-request
  |=  [url=purl non=@t bod=json]
  ^-  hiss
  :^  url  %post
    (my content-type+['application/jose+json' ~] ~)
  :-  ~
  ^-  octs
  =;  pro=json
    (as-octt:mimes:html (en-json:html (sign:jws key.act pro bod)))
  :-  %o  %-  my  :~
    nonce+s+non
    url+s+(crip (en-purl:html url))
    ?^  reg.act
      kid+s+kid.u.reg.act
    jwk+(pass:en:jwk key.act)
  ==
:: +bad-nonce: check if an http response is a badNonce error
::
++  bad-nonce
  |=  rep=httr
  ^-  ?
  :: XX always 400?
  ?.  =(400 p.rep)  |
  ?~  r.rep  |
  =/  jon=(unit json)  (de-json:html q.u.r.rep)
  ?~  jon  |
  :: XX unit parser, types
  =('urn:ietf:params:acme:error:badNonce' -:(error:grab u.jon))
:: |effect: send moves to advance
::
++  effect
  |%
  :: +directory: get ACME service directory
  ::
  ++  directory
    ^+  this
    (emit (request /acme/directory/(scot %p our.bow) bas %get ~ ~)) :: XX now?
  :: +nonce: get a new nonce for the next request
  ::
  ++  nonce
    |=  nex=@tas
    ~|  [%bad-nonce-next nex]
    ?>  ?=(nonce-next nex)
    ^+  this
    :: XX now?
    (emit (request /acme/nonce/next/[nex] non.dir %get ~ ~))
  :: +register: create ACME service account
  ::
  ::   Note: accepts services ToS.
  ::
  ++  register
    ^+  this
    ?~  nonces
      (nonce %register)
    %-  emit(nonces t.nonces, reg.act ~)
    %+  request
      /acme/register/(scot %p our.bow) :: XX now?
    %^  signed-request  reg.dir  i.nonces
    [%o (my [['termsOfServiceAgreed' b+&] ~])]
  :: XX rekey
  ::
  :: +new-order: create a new certificate order
  ::
  ++  new-order
    ^+  this
    ~|  %new-order-effect-fail
    ?.  ?=(^ reg.act)  ~|(%no-account !!)
    ?.  ?=([~ ^] pen)  ~|(%no-domains !!)
    ?~  nonces
      (nonce %new-order)
    %-  emit(nonces t.nonces)
    %+  request
      /acme/new-order/(scot %da now.bow)
    %^  signed-request  der.dir  i.nonces
    :-  %o  %-  my  :~
      :-  %identifiers
      :-  %a
      %+  turn
        ~(tap in `(set turf)`u.pen)
      |=(a=turf [%o (my type+s+'dns' value+s+(join '.' a) ~)])
    ==
  :: +finalize-order: finalize completed order
  ::
  ++  finalize-order
    ^+  this
    ~|  %finalize-order-effect-fail
    ?.  ?=(^ reg.act)  ~|(%no-account !!)
    ?.  ?=(^ rod)      ~|(%no-active-order !!)
    ?.  ?=(~ pending.aut.u.rod)  ~|(%pending-authz !!)
    ?.  ?=(~ active.aut.u.rod)   ~|(%active-authz !!)
    :: XX revisit wrt rate limits
    ?>  ?=(%wake sas.u.rod)
    ?~  nonces
      (nonce %finalize-order)
    %-  emit(nonces t.nonces)
    %+  request
      /acme/finalize-order/(scot %da now.bow)
    %^  signed-request  fin.u.rod  i.nonces
    [%o (my csr+s+(en-base64url (met 3 csr.u.rod) `@`csr.u.rod) ~)]
  :: +check-order: check completed order for certificate availability
  ::
  ++  check-order
    ^+  this
    ~|  %check-order-effect-fail
    ?.  ?=(^ reg.act)  ~|(%no-account !!)
    ?.  ?=(^ rod)      ~|(%no-active-order !!)
    ?.  ?=(~ pending.aut.u.rod)  ~|(%pending-authz !!)
    ?.  ?=(~ active.aut.u.rod)   ~|(%active-authz !!)
    :: XX revisit wrt rate limits
    ?>  ?=(%wake sas.u.rod)
    (emit (request /acme/check-order/(scot %da now.bow) ego.u.rod %get ~ ~))
  :: +certificate: download PEM-encoded certificate
  ::
  ++  certificate
    |=  url=purl
    ^+  this
    ~|  %certificate-effect-fail
    ?.  ?=(^ reg.act)  ~|(%no-account !!)
    ?.  ?=(^ rod)      ~|(%no-active-order !!)
    =/  hed  (my accept+['applicate/x-pem-file' ~] ~)
    (emit (request /acme/certificate/(scot %da now.bow) url %get hed ~))
  :: +install: tell %eyre about our certificate
  ::
  ++  install
    ^+  this
    ~|  %install-effect-fail
    ?>  ?=(^ liv)
    =/  key=wain  (ring:en:pem:pkcs8 key.u.liv)
    (emit %rule /install %cert `[key `wain`cer.u.liv])
  :: +get-authz: get next ACME service domain authorization object
  ::
  ++  get-authz
    ^+  this
    ~|  %get-authz-effect-fail
    ?.  ?=(^ reg.act)  ~|(%no-account !!)
    ?.  ?=(^ rod)      ~|(%no-active-order !!)
    ?.  ?=(^ pending.aut.u.rod)  ~|(%no-pending-authz !!)
    :: XX revisit wrt rate limits
    ?>  ?=(%wake sas.u.rod)
    %-  emit
    (request /acme/get-authz/(scot %da now.bow) i.pending.aut.u.rod %get ~ ~)
  :: XX check/finalize-authz ??
  ::
  :: +save-trial: save ACME domain validation challenge to /.well-known/
  ::
  ++  save-trial
    ^+  this
    ~|  %save-trial-effect-fail
    ?.  ?=(^ reg.act)  ~|(%no-account !!)
    ?.  ?=(^ rod)      ~|(%no-active-order !!)
    ?.  ?=(^ active.aut.u.rod)  ~|(%no-active-authz !!)
    :: XX revisit wrt rate limits
    ?>  ?=(%wake sas.u.rod)
    =*  aut  u.active.aut.u.rod
    %-  emit
    :^    %well
        :: XX idx in wire?
        /acme/save-trial/(scot %da now.bow)
      /acme-challenge/[tok.cal.aut]
    :+  ~
      /text/plain
    %-  as-octs:mimes:html
    (rap 3 [tok.cal.aut '.' (pass:thumb:jwk key.act) ~])
  :: +test-trial: confirm that ACME domain validation challenge is available
  ::
  ++  test-trial
    ^+  this
    ~|  %test-trial-effect-fail
    ?.  ?=(^ reg.act)  ~|(%no-account !!)
    ?.  ?=(^ rod)      ~|(%no-active-order !!)
    ?.  ?=(^ active.aut.u.rod)  ~|(%no-active-authz !!)
    :: XX revisit wrt rate limits
    ?>  ?=(%wake sas.u.rod)
    =*  aut  u.active.aut.u.rod
    =/  pat=path  /'.well-known'/acme-challenge/[tok.cal.aut]
    :: note: requires port 80, just as the ACME service will
    =/  url=purl  [[sec=| por=~ hos=[%& dom.aut]] [ext=~ pat] hed=~]
    :: =/  url=purl  [[sec=| por=`8.081 hos=[%& /localhost]] [ext=~ pat] hed=~]
    :: XX idx in wire?
    (emit (request /acme/test-trial/(scot %da now.bow) url %get ~ ~))
  :: +finalize-trial: notify ACME service that challenge is ready
  ::
  ++  finalize-trial
    ^+  this
    ~|  %finalize-trial-effect-fail
    ?.  ?=(^ reg.act)  ~|(%no-account !!)
    ?.  ?=(^ rod)      ~|(%no-active-order !!)
    ?.  ?=(^ active.aut.u.rod)  ~|(%no-active-authz !!)
    :: XX revisit wrt rate limits
    ?>  ?=(%wake sas.u.rod)
    =*  aut  u.active.aut.u.rod
    ?~  nonces
      (nonce %finalize-trial)
    %-  emit(nonces t.nonces)
    %+  request
      :: XX idx in wire?
      /acme/finalize-trial/(scot %da now.bow)
    :: empty object included for signature
    (signed-request ego.cal.aut i.nonces [%o ~])
  ::  XX delete-trial?
  ::
  :: +retry: retry effect after timeout
  ::
  ++  retry
    |=  [wir=wire wen=@da]
    :: XX validate wire and date
    (emit %wait [%acme wir] wen)
  --
:: |event: accept event, emit next effect(s)
::
::   XX should these next effects be triggered at call sites instead?
::
++  event
  |%
  :: +directory: accept ACME service directory, trigger registration
  ::
  ++  directory
    |=  [wir=wire rep=httr]
    ^+  this
    ?.  =(200 p.rep)
      :: XX never happened yet, wat do?
      ~&  [%directory-fail rep]
      this
    =.  dir  (directory:grab (need (de-json:html q:(need r.rep))))
    ?~(reg.act register:effect this)
  :: +nonce: accept new nonce and trigger next effect
  ::
  ::   Nonce has already been saved in +sigh-httr. The next effect
  ::   is specified in the wire.
  ::
  ++  nonce
    |=  [wir=wire rep=httr]
    ^+  this
    ~|  [%unrecognized-nonce-wire wir]
    ?>  &(?=(^ wir) ?=([%next ^] t.wir))
    =*  nex  i.t.t.wir
    ~|  [%unknown-nonce-next nex]
    ?>  ?=(nonce-next nex)
    ?.  =(204 p.rep)
      :: cttp i/o timeout, always retry
      :: XX set timer to backoff?
      ?:  =(504 p.rep)  (nonce:effect nex)
      :: XX never happened yet, retry nonce anyway?
      ::
      ~&([%nonce-fail wir rep] this)
    ?-  nex
      %register        register:effect
      %new-order       new-order:effect
      %finalize-order  finalize-order:effect
      %finalize-trial  finalize-trial:effect
    ==
  :: +register: accept ACME service registration
  ::
  ++  register
    |=  [wir=wire rep=httr]
    ^+  this
    ?.  =(201 p.rep)
      ::XX 204?
      ?:  (bad-nonce rep)
        (nonce:effect %register)
      :: XX retry immediately or backoff?
      ~&  [%register-fail wir rep]
      this
    =/  loc=@t
      q:(head (skim q.rep |=((pair @t @t) ?=(%location p))))
    =/  wen=@t              :: XX @da
      ?~  r.rep
        (scot %da now.bow)
      =/  bod=[id=@t wen=@t sas=@t]
        (acct:grab (need (de-json:html q.u.r.rep)))
      ?>  ?=(%valid sas.bod)
      wen.bod
    =.  reg.act  `[wen loc]
    ?~(pen this new-order:effect)
  :: XX rekey
  ::
  ::  +new-order: order created, begin processing authorizations
  ::
  ++  new-order
    |=  [wir=wire rep=httr]
    ^+  this
    ?.  =(201 p.rep)
      ?:  (bad-nonce rep)
        (nonce:effect %new-order)
      :: XX retry immediately or backoff?
      :: XX possible 204?
      ~&  [%new-order-fail wir rep]
      this
    :: XX delete order if not?
    ?>  ?=(^ pen)
    =/  loc=@t
      q:(head (skim q.rep |=((pair @t @t) ?=(%location p))))
    =/  ego=purl  (need (de-purl:html loc))
    :: XX add parser output types
    :: XX parse identifiers, confirm equal to pending domains
    :: XX check status
    =/  bod=[aut=(list purl) fin=purl exp=@t sas=@t]
      (order:grab (need (de-json:html q:(need r.rep))))
    :: XX maybe generate key here?
    =/  csr=@ux  +:(en:der:pkcs10 cey ~(tap in u.pen))
    =/  dor=order
      [dom=u.pen sas=%wake exp.bod ego fin.bod cey csr [aut.bod ~ ~]]
    get-authz:effect(rod `dor, pen ~)
  :: +finalize-order: order finalized, poll for certificate
  ::
  ++  finalize-order
    |=  [wir=wire rep=httr]
    ^+  this
    ?.  =(200 p.rep)
      ?:  (bad-nonce rep)
        (nonce:effect %finalize-order)
      ~&  [%finalize-order-fail wir rep]
      ?>  ?=(^ rod)
      :: XX get the failure reason
      this(rod ~, fal.hit [u.rod fal.hit])
    ?>  ?=(^ rod)
    :: XX rep body missing authorizations, need flexible/separate parser
    :: XX finalizing-order
    :: =/  bod=[aut=(list purl) fin=purl exp=@t sas=@t]
    ::   (order:grab (need (de-json:html q:(need r.rep))))
    :: XX check status? (i don't think failures get here)
    check-order:effect
  ::  +check-order: check if certificate is ready for finalized order
  ::
  ++  check-order
    |=  [wir=wire rep=httr]
    ^+  this
    ?.  =(200 p.rep)
      :: XX retry immediately? backoff?
      ~&  [%check-order-fail wir rep]
      this
    ?>  ?=(^ rod)
    =/  raw=json
      (need (de-json:html q:(need r.rep)))
    =/  bod=[exp=@t sas=@t]
      (finalizing-order:grab raw)
    ?+  sas.bod
      ~&  [%check-order-status-unknown sas.bod]
      this
    ::
        %invalid
      ~&  [%check-order-fail %invalid wir rep]
      :: XX check authz for debug info
      :: XX send notification somehow?
      :: XX start over with new order?
      this
    ::
        %pending
      check-order:effect
    ::
        %processing
      check-order:effect
    ::
        %valid
      :: XX json reparser unit
      =/  bod=[exp=@t sas=@t cer=purl]
        (final-order:grab raw)
      :: XX update order state
      :: XX =< delete-trial
      (certificate:effect cer.bod)
    ==
  ::
  :: +certificate: accept PEM-encoded certificate
  ::
  ++  certificate
    |=  [wir=wire rep=httr]
    ^+  this
    ?.  =(200 p.rep)
      :: XX retry immediately? backoff?
      ~&  [%certificate-fail wir rep]
      this
    ?>  ?=(^ rod)
    =/  cer=wain  (to-wain:format q:(need r.rep))
    =/  fig=config
      :: XX expiration date
      [dom.u.rod key.u.rod cer (add now.bow ~d90) ego.u.rod]
    =?  fig.hit  ?=(^ liv)  [u.liv fig.hit]
    :: XX set renewal timer
    install:effect(liv `fig, rod ~)
  :: +get-authz: accept ACME service authorization object
  ::
  ++  get-authz
    |=  [wir=wire rep=httr]
    ^+  this
    ?.  =(200 p.rep)
      :: XX retry immediately? backoff?
      ~&  [%get-authz-fail wir rep]
      this
    ?>  ?=(^ rod)
    ?>  ?=(^ pending.aut.u.rod)
    :: XX parser types
    =/  bod=[dom=turf sas=@t exp=@t cal=[typ=@t sas=@t ego=purl tok=@t]]
      (auth:grab (need (de-json:html q:(need r.rep))))
    =/  cal=trial
       :: XX parse token to verify url-safe base64?
      [%http ego.cal.bod tok.cal.bod %recv]
    :: XX check that URLs are the same
   =/  tau=auth  [i.pending.aut.u.rod dom.bod cal]
    :: XX get idx from wire instead?
    =/  idx=@ud  +((lent done.aut.u.rod))
    =/  rod-aut=order-auth
      %=  aut.u.rod
        pending  t.pending.aut.u.rod
        active   `[idx tau]
      ==
    =<  test-trial:effect
    save-trial:effect(aut.u.rod rod-aut)
  :: XX check/finalize-authz ??
  ::
  :: +test-trial: accept response from challenge test
  ::
  ::   Note that +save-trail:effect has no corresponding event.
  ::
  ++  test-trial
    |=  [wir=wire rep=httr]
    ^+  this
    ?.  =(200 p.rep)
      :: XX count retries, backoff
      ~&  [%test-trial-fail wir rep]
      (retry:effect /test-trial (add now.bow ~m10))
    ?>  ?=(^ rod)
    ?>  ?=(^ active.aut.u.rod)
    :: XX check content type and response body
    finalize-trial:effect
  :: +finalize-trial:
  ::
  ++  finalize-trial
    |=  [wir=wire rep=httr]
    ^+  this
    ?.  =(200 p.rep)
      ?:  (bad-nonce rep)
        (nonce:effect %finalize-trial)
      :: XX retry? or cancel order?
      :: XX 204 assume pending?
      ~&  [%finalize-trial-fail wir rep]
      :: XX handle "challenge is not pending"
      this
    ?>  ?=(^ rod)
    ?>  ?=(^ active.aut.u.rod)
    =*  aut  u.active.aut.u.rod
    =/  bod=[typ=@t sas=@t url=purl tok=@t]
      (challenge:grab (need (de-json:html q:(need r.rep))))
    :: XX check for other possible values in 200 response
    :: note: may have already been validated
    ?>  ?=(?(%pending %valid) sas.bod)
    =/  rod-aut=order-auth
      aut.u.rod(active ~, done [+.aut(sas.cal %pend) done.aut.u.rod])
    ?~  pending.aut.u.rod
      finalize-order:effect(aut.u.rod rod-aut)
    get-authz:effect(aut.u.rod rod-aut)
  ::  XX delete-trial?
  ::
  :: +retry: retry effect after timeout
  ::
  ++  retry
    |=  wir=wire
    ^+  this
    ?+  wir
        ~&(unknown-retry+wir this)
      :: XX do the needful
      [%directory ~]  directory:effect
      [%test-trial ~]  test-trial:effect
    ==
  --
:: +sigh-tang: handle http request failure
::
++  sigh-tang
  |=  [wir=wire saw=tang]
  ^-  (quip move _this)
  ~&  [%sigh-tang wir]
  :: XX take evasive action
  [((slog saw) ~) this]
:: +sigh-recoverable-error: handle http rate-limit response
::
++  sigh-recoverable-error
  |=  [wir=wire %429 %rate-limit lim=(unit @da)]
  ^-  (quip move _this)
  ~&  [%sigh-recoverable wir lim]
  :: XX retry
  [~ this]
:: +sigh-httr: accept http response
::
++  sigh-httr
  |=  [wir=wire rep=httr]
  ^-  (quip move _this)
  ~&  [wir rep]
  ?>  ?=([%acme ^] wir)
  :: add nonce to pool, if present
  =/  nonhed  (skim q.rep |=((pair @t @t) ?=(%replay-nonce p)))
  =?  nonces  ?=(^ nonhed)  [q.i.nonhed nonces]
  =<  abet
  ~|  [%sigh-fail wir rep]
  %.  [t.wir rep]
  ?+  i.t.wir
      ~&([%unknown-wire i.t.wir] !!)
    %directory       directory:event
    %nonce           nonce:event
    %register        register:event
    :: XX rekey
    %new-order       new-order:event
    %finalize-order  finalize-order:event
    %check-order     check-order:event
    %certificate     certificate:event
    %get-authz       get-authz:event
    :: XX check/finalize-authz ??
    %test-trial      test-trial:event
    %finalize-trial  finalize-trial:event
    ::  XX delete-trial?
  ==
:: +wake: timer wakeup event
::
++  wake
  |=  [wir=wire ~]
  ^-  (quip move _this)
  ~&  [%wake wir]
  ?>  ?=([%acme *] wir)
  abet:(retry:event t.wir)
:: +poke-acme-order: create new order for a set of domains
::
++  poke-acme-order
  |=  a=(set turf)
  ~&  [%poke-acme a]
  abet:(add-order a)
:: +poke-noun: for debugging
::
++  poke-noun
  |=  a=*
  ^-  (quip move _this)
  =<  abet
  ?+  a
      ~&(+<+.this this)
    %dbug  ~&  [%private (ring:en:pem:pkcs1 key.act)]
           ~&  [%public (pass:en:pem:pkcs1 key.act)]
           this
    %init   init
    %reg    register:effect
    %order  new-order:effect
    %auth   get-authz:effect
    %trial  test-trial:effect
    %final  finalize-order:effect
    %poll   check-order:effect
    %our    (add-order (sy /org/urbit/(crip +:(scow %p our.bow)) ~))
    %rule   install:effect
    %fake   fake
    %none   none
    %test   test
  ==
++  none
  ^+  this
  (emit %rule /uninstall %cert ~)
++  fake
  ^+  this
  =/  key=wain
    :~  '-----BEGIN RSA PRIVATE KEY-----'
        'MIIEpAIBAAKCAQEAisQPzzmGWNZSNNAwY59XrqK/bU0NKNZS2ETOiJeSpzPAHYl+'
        'c39V96/QUR0tra2zQI4QD6kpMYX/7R5nwuvsA4o7ypfYupNrlzLPThCKEHpZomDD'
        '0Bb3T8u7YGrMjEX5cOmZIU2T/iy4GK/wWuBIy2TEp/0J+RoSCIr8Df/A7GIM8bwn'
        'v23Vq0kE2xBqqaT5LjvuQoXfiLJ42F33DDno9lVikKEyt55D/08rH41KpXvn3tWZ'
        '46tZK6Ds7Zr1hEV1LbDx1CXDzQ6gKObBe54DWDV3h7TJhr0BSW68dFJhro7Y60Ns'
        'zTcFqY1RC9F0ePtsnKGFzMOe/U+fPvsGe2oWvwIDAQABAoIBACCf19ewfpWETe98'
        'wuOpIsQ8HyVjaCShvvh5tNUITcJhuFk5ajFdTqjc/O0VHxgmLm6O99e2vaiXCISH'
        'EX4SWXq7lTMcYCf9YN47Y+HGoa8eFNTIS0ExJRPtojAY695O1UZmpUnfI1wux1mG'
        'g8vZz0OCfXnBVAbsyjCX/IqOBp2MVzfMyMuaF/oQ2xiX4AZ1hDIMDpUTGw7OKX15'
        'JAUlTZUhzifmijPg1gViD8Lf5w42nlwYPC5j6wWKpJSx76CNUxLdJAaaZb3QYE96'
        'zu/jOCdy25sPHIux3XTdV6fqZ2iTvt31+bcnSAvmbDpmcujsZPVRXRu5OO/0xBh6'
        'GGlTLAECgYEAwSyNkbNk0mBRxet68IW02wXYaxIEVUWqhSeE2MGaXg4h9VSgh83q'
        '7wly0ujy9Sj79aF2frkpMbIoeeGIOTIYI4RCYuBKx+/NNWFoggu4UK5xOMr0dfQK'
        '2Ggr2agUH3KExvOpAW3rvWzepLl8ppySLNipLcFQHOJ0kxwPd2ig3Z8CgYEAt+WM'
        'JoW9dLxUu/zTih5Dacubl+fnnm8BsypKmv88mzcqEVwXOo6Z6bmlw0NeWxmlwHu7'
        'vs+XQ8MDUDvQvIul8sFagZk7RvWcXTlaHtPQ1D8/ztrg5d58TwxpwXshBytfR6NA'
        'tIZa+tNvzQF5AKVlB+lZEWF6E6FoI5NmGDAZ8uECgYB4FV4cCMzQCphK1Muj4TpA'
        'PS3/wT94Usph4+Mta4yuk1KA047HXTaCSflbKvx9cnDOjQTAWhJFll6bBZxNEdr3'
        'mSw7kvppt6R1Xow861Q0s3wmteOpv39Ob9Nyho2bzvDDTIzvGonFQ3xUIgpe+E3W'
        'GwlwLA/FJPEa0gK7VAtMOQKBgQCgcPtX2LM0l+Ntp+V/yWuTb/quC7w+tCbNhAZX'
        'OHxOB1ECmFAD3MpX6oq+05YM8VF1n/5rOX6Ftiy74ZP6C/Sa2Sr3ixL2k+76PsFr'
        'x+2YYB5xgPFaXEQkS3YxQhXMxYB5ZetcFSRnVfVi7Pf/Ik4FGweEbIEvg1DySPV4'
        'AO+CwQKBgQCFnjHsFeNZVvtiL2wONT6osjRCpMvaUiVecMW9oUBtjpLHI2gQr7+4'
        'dvCm2Sj7uq9OWO0rBz1px/kI+ONjhwsFPLK5v8hyVDoIE791Qg3qAY1a6JOXRl9P'
        '6TBc3dQ2qUVqt8gi9RLCDFJU18Td6La4mkJSP5YrioGtwUJow0F07Q=='
        '-----END RSA PRIVATE KEY-----'
    ==

  =/  cert=wain
    :~  '-----BEGIN CERTIFICATE-----'
        'MIIF8jCCBNqgAwIBAgITAPrPc8Udwmv5dJ+hx2Uh+gZF1TANBgkqhkiG9w0BAQsF'
        'ADAiMSAwHgYDVQQDDBdGYWtlIExFIEludGVybWVkaWF0ZSBYMTAeFw0xODA3MDMx'
        'ODAyMTZaFw0xODEwMDExODAyMTZaMB8xHTAbBgNVBAMTFHpvZC5keW5kbnMudXJi'
        'aXQub3JnMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAisQPzzmGWNZS'
        'NNAwY59XrqK/bU0NKNZS2ETOiJeSpzPAHYl+c39V96/QUR0tra2zQI4QD6kpMYX/'
        '7R5nwuvsA4o7ypfYupNrlzLPThCKEHpZomDD0Bb3T8u7YGrMjEX5cOmZIU2T/iy4'
        'GK/wWuBIy2TEp/0J+RoSCIr8Df/A7GIM8bwnv23Vq0kE2xBqqaT5LjvuQoXfiLJ4'
        '2F33DDno9lVikKEyt55D/08rH41KpXvn3tWZ46tZK6Ds7Zr1hEV1LbDx1CXDzQ6g'
        'KObBe54DWDV3h7TJhr0BSW68dFJhro7Y60NszTcFqY1RC9F0ePtsnKGFzMOe/U+f'
        'PvsGe2oWvwIDAQABo4IDIjCCAx4wDgYDVR0PAQH/BAQDAgWgMB0GA1UdJQQWMBQG'
        'CCsGAQUFBwMBBggrBgEFBQcDAjAMBgNVHRMBAf8EAjAAMB0GA1UdDgQWBBTokXAU'
        'vPwcrbkLxcVBCNNQ588pfjAfBgNVHSMEGDAWgBTAzANGuVggzFxycPPhLssgpvVo'
        'OjB3BggrBgEFBQcBAQRrMGkwMgYIKwYBBQUHMAGGJmh0dHA6Ly9vY3NwLnN0Zy1p'
        'bnQteDEubGV0c2VuY3J5cHQub3JnMDMGCCsGAQUFBzAChidodHRwOi8vY2VydC5z'
        'dGctaW50LXgxLmxldHNlbmNyeXB0Lm9yZy8wHwYDVR0RBBgwFoIUem9kLmR5bmRu'
        'cy51cmJpdC5vcmcwgf4GA1UdIASB9jCB8zAIBgZngQwBAgEwgeYGCysGAQQBgt8T'
        'AQEBMIHWMCYGCCsGAQUFBwIBFhpodHRwOi8vY3BzLmxldHNlbmNyeXB0Lm9yZzCB'
        'qwYIKwYBBQUHAgIwgZ4MgZtUaGlzIENlcnRpZmljYXRlIG1heSBvbmx5IGJlIHJl'
        'bGllZCB1cG9uIGJ5IFJlbHlpbmcgUGFydGllcyBhbmQgb25seSBpbiBhY2NvcmRh'
        'bmNlIHdpdGggdGhlIENlcnRpZmljYXRlIFBvbGljeSBmb3VuZCBhdCBodHRwczov'
        'L2xldHNlbmNyeXB0Lm9yZy9yZXBvc2l0b3J5LzCCAQIGCisGAQQB1nkCBAIEgfME'
        'gfAA7gB1ALDMg+Wl+X1rr3wJzChJBIcqx+iLEyxjULfG/SbhbGx3AAABZGGGG6QA'
        'AAQDAEYwRAIgJHrIawVea5/++wteocdbt1QUBxysW7uJqYgvnOWOQMgCIGRlioyE'
        'vzunUm/HZre3fF2jBsJr45C1tz5FTe/cYQwmAHUA3Zk0/KXnJIDJVmh9gTSZCEmy'
        'Sfe1adjHvKs/XMHzbmQAAAFkYYYjLQAABAMARjBEAiAWovIKERYeNbJlAKvNorwn'
        'RnSFP0lJ9sguwcpbcsYJ1gIgRJxTolkMOr0Fwq62q4UYnpREY8zu4hiL90Mhntky'
        'EwYwDQYJKoZIhvcNAQELBQADggEBAMYxvA+p4Qj0U23AHAe61W3+M6T1M0BfrGE2'
        'jJCaq4c3d7b9NEN1qFJHl8t/+Z/7RHUIzbm4CIOZynSM8mBxg2NgXymvXQkRrrBo'
        'fhO9u8Yxizx4+KOtiigt9JBVlpyCm6I9uifM+7rZYh45s2IkfDBPKd+M1tfIUOne'
        'YgUt1YguEkM2xqRG16JyHA0Xwn6mn+4pWiTdfNzlqol6vyGT7WfIvmV7cdGoYKjB'
        'wOt/g1wWMTwhSWBCVqCyn+f2rl8u3wbXrIUeRng2ryNVXO03nukTp7OLN3HUO6PR'
        'hC4NdS4o2geBNZr8RJiORtCelDaJprY7lhh2MFzVpsodc2eB5sQ='
        '-----END CERTIFICATE-----'
        ''
        '-----BEGIN CERTIFICATE-----'
        'MIIEqzCCApOgAwIBAgIRAIvhKg5ZRO08VGQx8JdhT+UwDQYJKoZIhvcNAQELBQAw'
        'GjEYMBYGA1UEAwwPRmFrZSBMRSBSb290IFgxMB4XDTE2MDUyMzIyMDc1OVoXDTM2'
        'MDUyMzIyMDc1OVowIjEgMB4GA1UEAwwXRmFrZSBMRSBJbnRlcm1lZGlhdGUgWDEw'
        'ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDtWKySDn7rWZc5ggjz3ZB0'
        '8jO4xti3uzINfD5sQ7Lj7hzetUT+wQob+iXSZkhnvx+IvdbXF5/yt8aWPpUKnPym'
        'oLxsYiI5gQBLxNDzIec0OIaflWqAr29m7J8+NNtApEN8nZFnf3bhehZW7AxmS1m0'
        'ZnSsdHw0Fw+bgixPg2MQ9k9oefFeqa+7Kqdlz5bbrUYV2volxhDFtnI4Mh8BiWCN'
        'xDH1Hizq+GKCcHsinDZWurCqder/afJBnQs+SBSL6MVApHt+d35zjBD92fO2Je56'
        'dhMfzCgOKXeJ340WhW3TjD1zqLZXeaCyUNRnfOmWZV8nEhtHOFbUCU7r/KkjMZO9'
        'AgMBAAGjgeMwgeAwDgYDVR0PAQH/BAQDAgGGMBIGA1UdEwEB/wQIMAYBAf8CAQAw'
        'HQYDVR0OBBYEFMDMA0a5WCDMXHJw8+EuyyCm9Wg6MHoGCCsGAQUFBwEBBG4wbDA0'
        'BggrBgEFBQcwAYYoaHR0cDovL29jc3Auc3RnLXJvb3QteDEubGV0c2VuY3J5cHQu'
        'b3JnLzA0BggrBgEFBQcwAoYoaHR0cDovL2NlcnQuc3RnLXJvb3QteDEubGV0c2Vu'
        'Y3J5cHQub3JnLzAfBgNVHSMEGDAWgBTBJnSkikSg5vogKNhcI5pFiBh54DANBgkq'
        'hkiG9w0BAQsFAAOCAgEABYSu4Il+fI0MYU42OTmEj+1HqQ5DvyAeyCA6sGuZdwjF'
        'UGeVOv3NnLyfofuUOjEbY5irFCDtnv+0ckukUZN9lz4Q2YjWGUpW4TTu3ieTsaC9'
        'AFvCSgNHJyWSVtWvB5XDxsqawl1KzHzzwr132bF2rtGtazSqVqK9E07sGHMCf+zp'
        'DQVDVVGtqZPHwX3KqUtefE621b8RI6VCl4oD30Olf8pjuzG4JKBFRFclzLRjo/h7'
        'IkkfjZ8wDa7faOjVXx6n+eUQ29cIMCzr8/rNWHS9pYGGQKJiY2xmVC9h12H99Xyf'
        'zWE9vb5zKP3MVG6neX1hSdo7PEAb9fqRhHkqVsqUvJlIRmvXvVKTwNCP3eCjRCCI'
        'PTAvjV+4ni786iXwwFYNz8l3PmPLCyQXWGohnJ8iBm+5nk7O2ynaPVW0U2W+pt2w'
        'SVuvdDM5zGv2f9ltNWUiYZHJ1mmO97jSY/6YfdOUH66iRtQtDkHBRdkNBsMbD+Em'
        '2TgBldtHNSJBfB3pm9FblgOcJ0FSWcUDWJ7vO0+NTXlgrRofRT6pVywzxVo6dND0'
        'WzYlTWeUVsO40xJqhgUQRER9YLOLxJ0O6C8i0xFxAMKOtSdodMB3RIwt7RFQ0uyt'
        'n5Z5MqkYhlMI3J1tPRTp1nEt9fyGspBOO05gi148Qasp+3N+svqKomoQglNoAxU='
        '-----END CERTIFICATE-----'
    ==
  =/  k=key:rsa  (need (ring:de:pem:pkcs1 key))
  =/  k8=wain  (ring:en:pem:pkcs8 k)
  (emit %rule /install %cert `[k8 cert])
:: +poke-path: for debugging
::
++  poke-path
  |=(a=path abet:(add-order (sy a ~)))
::
:: ++  prep  _[~ this]
++  prep
  |=  old=(unit acme)
  ^-  (quip move _this)
  ?~  old
    [~ this]
  [~ this(+<+ u.old)]
::
++  rekey                             :: XX do something about this
  |=  eny=@
  =|  i=@
  |-  ^-  key:rsa
  =/  k  (new-key:rsa 2.048 eny)
  =/  m  (met 0 n.pub.k)
  :: ?:  =(0 (mod m 8))  k
  ?:  =(2.048 m)  k
  ~&  [%key iter=i width=m]
  $(i +(i), eny +(eny))
::
++  init
  =/  url
    'https://acme-staging-v02.api.letsencrypt.org/directory'
  =<  (retry:effect /directory +(now.bow))
  %=  this
    bas  (need (de-purl:html url))
    act  [(rekey eny.bow) ~]
    cey  (rekey (mix eny.bow (shaz now.bow)))
  ==
::
++  add-order
  |=  dom=(set turf)
  ^+  this
  ?:  ?=(?(%earl %pawn) (clan:title our.bow))
    this
  :: set pending order
  ::
  =.  pen  `dom
  :: archive active order if exists
  ::
  ::   XX we may have pending moves out for this order
  ::   put dates in wires, check against order creation date?
  ::   or re-use order-id?
  ::
  =?  fal.hit  ?=(^ rod)  [u.rod fal.hit]
  =.  rod  ~
  :: if registered, create order
  ::
  ?^  reg.act
    new-order:effect
  :: if initialized, defer
  ::
  ?.(=(act *acct) this init)
::
++  test
  =,  tester:tester
  =/  eny  eny.bow
    :: non-deterministic for now
    :: 0vhu.gp79o.hi7at.smp8u.g5hhr.u3rff.st8ms.q4dc2.hv5ls.tp5cp.10qds.
    ::      h9bpt.vlmm7.lh375.f6u9n.krqv8.5jcml.cujkr.v1uqv.cjhe5.nplta
  |^  =/  out=tang
          ;:  weld
            test-base64
            test-asn1
            test-rsakey
            test-rsa
            test-rsapem
            test-rsa-pkcs8
            test-rsa-pem-zero
            test-rs256
            test-jwk
            test-jws
            test-jws-2
            test-csr
          ==
      ?~(out this ((slog out) this))
  ::
  ++  test-base64
    ;:  weld
      %-  expect-eq  !>
        ['AQAB' (en-base64url (en:octn 65.537))]
      %-  expect-eq  !>
        [65.537 (de:octn (need (de-base64url 'AQAB')))]
      :: echo "hello" | base64
      %-  expect-eq  !>
        ['aGVsbG8K' (en:base64 (as-octs:mimes:html 'hello\0a'))]
      %-  expect-eq  !>
        ['hello\0a' +:(need (de:base64 'aGVsbG8K'))]
      :: echo -n -e "\x01\x01\x02\x03" | base64
      %-  expect-eq  !>
        ['AQECAw==' (en:base64 (en:octn 0x101.0203))]
      %-  expect-eq  !>
        [0x302.0101 +:(need (de:base64 'AQECAw=='))]
    ==
  ::
  ++  test-asn1
    =/  nul=spec:asn1  [%nul ~]
    =/  int=spec:asn1  [%int 187]
    =/  obj=spec:asn1  [%obj sha-256:obj:asn1]
    =/  oct=spec:asn1  [%oct 32 (shax 'hello\0a')]
    =/  seq=spec:asn1  [%seq [%seq obj nul ~] oct ~]
    ;:  weld
      %-  expect-eq  !>
        :-  [0x5 0x0 ~]
        ~(ren raw:en:der nul)
      %-  expect-eq  !>
        [nul (scan ~(ren raw:en:der nul) parse:de:der)]
      %-  expect-eq  !>
        :-  [0x2 0x2 0x0 0xbb ~]
        ~(ren raw:en:der int)
      %-  expect-eq  !>
        [int (scan ~(ren raw:en:der int) parse:de:der)]
      %-  expect-eq  !>
        :-  [0x6 0x9 0x60 0x86 0x48 0x1 0x65 0x3 0x4 0x2 0x1 ~]
        ~(ren raw:en:der obj)
      %-  expect-eq  !>
        [obj (scan ~(ren raw:en:der obj) parse:de:der)]
      %-  expect-eq  !>
        :-    0x420.5891.b5b5.22d5.df08.6d0f.f0b1.10fb.
          d9d2.1bb4.fc71.63af.34d0.8286.a2e8.46f6.be03
        `@ux`(swp 3 +:(en:der oct))
      %-  expect-eq  !>
        [oct (scan ~(ren raw:en:der oct) parse:de:der)]
      %-  expect-eq  !>
        :-  0x30.3130.0d06.0960.8648.0165.0304.0201.0500.0420.5891.b5b5.22d5.
            df08.6d0f.f0b1.10fb.d9d2.1bb4.fc71.63af.34d0.8286.a2e8.46f6.be03
        `@ux`(swp 3 +:(en:der seq))
      %-  expect-eq  !>
        [seq (scan ~(ren raw:en:der seq) parse:de:der)]
    ==
  ::
  ++  test-rsakey
    =/  primes=(list @)
      :~    2    3    5    7   11   13   17   19   23   29   31   37   41   43
           47   53   59   61   67   71   73   79   83   89   97  101  103  107
          109  113  127  131  137  139  149  151  157  163  167  173  179  181
          191  193  197  199  211  223  227  229  233  239  241  251  257  263
          269  271  277  281  283  293  307  311  313  317  331  337  347  349
          353  359  367  373  379  383  389  397  401  409  419  421  431  433
          439  443  449  457  461  463  467  479  487  491  499  503  509  521
          523  541  547  557  563  569  571  577  587  593  599  601  607  613
          617  619  631  641  643  647  653  659  661  673  677  683  691  701
          709  719  727  733  739  743  751
      ==
    =/  k1  (new-key:rsa 2.048 eny)
    ::
    =/  k2=key:rsa
      =/  p  0x1837.be57.1286.bf6a.3cf8.4716.634f.ef85.f947.c654.da6e.e222.
          5654.9466.0ab0.a2ef.1985.1095.e3c3.9e74.9478.e3f3.ee92.f885.ec3c.
          84c3.6b3c.9731.65f9.9d1d.f743.646f.37d7.82d8.3f4a.856c.6453.b2c8.
          28d5.d720.145e.c7ab.4ba9.a9c2.6b8e.8819.7aa8.69b3.420f.dbfa.1ddb.
          4d1a.9c2e.e25a.d4de.d351.945f.d7ca.74a4.815d.5f0e.9f44.df64.39bd
      =/  q  0xf1bc.ec8f.d238.32d9.afb8.8083.76b3.82da.6274.f56e.1b5b.662b.
          ab1b.1e01.fbd5.86c5.ba98.b246.b621.f190.2425.25ea.b39f.efa2.4fb8.
          0d6b.c3c4.460d.e7df.d2f5.6604.51e0.415b.db60.db5a.6601.16c7.46ec.
          5e67.9195.f3c9.80d3.47c5.fe24.fbfd.43c3.380a.40bd.c4f5.d65e.b93b.
          60ca.5f26.4ed7.9c64.d26d.b0fe.985d.7be3.1308.34dd.b8c5.4d7c.d8a5
      =/  n  (mul p q)
      =/  e  0x1.0001
      =/  d  (~(inv fo (elcm:rsa (dec p) (dec q))) e)
      [[n e] `[d p q]]
    ::
    |^  ^-  tang
        ;:  weld
            (check-primes k1)
            (check-primes k2)
        ==
    ++  check-primes
      =,  number
      |=  k=key:rsa
      ?>  ?=(^ sek.k)
      %+  roll  primes
      |=  [p=@ a=tang]
      ?^  a  a
      ?:  =(0 (mod n.pub.k p))
        :~  leaf+"{(scow %ux n.pub.k)}"
            :-  %leaf
            %+  weld
              "n.pub.key (prime? {(scow %f (pram n.pub.k))})"
            " divisible by {(scow %ud p)}:"
        ==
      ?:  =(0 (mod p.u.sek.k p))
        :~  leaf+"{(scow %ux p.u.sek.k)}"
            :-  %leaf
            %+  weld
              "p.u.sek.key (prime? {(scow %f (pram p.u.sek.k))})"
            " divisible by {(scow %ud p)}:"
        ==
      ?:  =(0 (mod q.u.sek.k p))
        :~  leaf+"{(scow %ux q.u.sek.k)}"
            :-  %leaf
            %+  weld
              "q.u.sek.key (prime? {(scow %f (pram q.u.sek.k))})"
            " divisible by {(scow %ud p)}:"
        ==
      ~
    --
  ::
  ++  test-rsapem
    ::  ex from https://stackoverflow.com/a/19855935
    =/  k1=key:rsa
      :-  [`@ux`187 `@ux`7]
      [~ `@ux`23 `@ux`17 `@ux`11]
    =/  kpem1=wain
      :~  '-----BEGIN RSA PRIVATE KEY-----'
          'MBwCAQACAgC7AgEHAgEXAgERAgELAgEHAgEDAgEO'
          '-----END RSA PRIVATE KEY-----'
      ==
    =/  k2=key:rsa
      :*  [n=`@ux`16.238.973.331.713.186.433 e=`@ux`65.537]
          ~
          d=`@ux`3.298.243.342.098.580.397
          p=`@ux`4.140.273.707
          q=`@ux`3.922.198.019
      ==
    :: openssl genrsa -out private.pem 64
    =/  kpem2=wain
      :~  '-----BEGIN RSA PRIVATE KEY-----'
          'MEACAQACCQDhXGw1Gc5agQIDAQABAggtxbbYRJVDrQIFAPbHkCsCBQDpx/4DAgUA'
          '23X55QIFAIpPROsCBQC56nYF'
          '-----END RSA PRIVATE KEY-----'
      ==
    :: openssl genrsa -out private.pem 2048
    =/  kpem3=wain
      :~  '-----BEGIN RSA PRIVATE KEY-----'
          'MIIEowIBAAKCAQEA2jJp8dgAKy5cSzDE4D+aUbKZsQoMhIWI2IFlE+AO0GCBMig5'
          'qxx2IIAPVIcSi5fjOLtTHnuIZYw+s06qeb8QIKRvkZaIwnA3Lz5UUrxgh96sezdX'
          'CCSG7FndIFskcT+zG00JL+fPRdlPjt1Vg2b3kneo5aAKMIPyOTzcY590UTc+luQ3'
          'HhgSiNF3n5YQh24d3kS2YOUoSXQ13+YRljxNfBgXbV+C7/gO8mFxpkafhmgkIGNe'
          'WlqT9oAIRa+gOx13uPAg+Jb/8lPV9bGaFqGvxvBMp3xUASlzYHiDntcB5MiOPRW6'
          'BoIGI5qDFSYRZBky9crE7WAYgqtPtg21zvxwFwIDAQABAoIBAH0q7GGisj4TIziy'
          '6k1lzwXMuaO4iwO+gokIeU5UessIgTSfpK1G73CnZaPstDPF1r/lncHfxZfTQuij'
          'WOHsO7kt+x5+R0ebDd0ZGVA45fsrPrCUR2XRZmDRECuOfTJGA13G7F1B0kJUbfIb'
          'gAGYIK8x236WNyIrntk804SGpTgstCsZ51rK5GL6diZVQbeU806oP1Zhx/ye//NR'
          'mS5G0iil//H41pV5WGomOX0mq9/HYBZqCncqzLki6FFdmXykjz8snvXUR40S8B+a'
          '0F/LN+549PSe2dp9h0Hx4HCJOsL9CyCQimqqqE8KPQ4BUz8q3+Mhx1xEyaxIlNH9'
          'ECgo1CECgYEA+mi7vQRzstYJerbhCtaeFrOR/n8Dft7FyFN+5IV7H2omy6gf0zr1'
          'GWjmph5R0sMPgL8uVRGANUrkuZZuCr35iY6zQpdCFB4D9t+zbTvTmrxt2oVaE16/'
          'dIJ6b8cHzR2QrEh8uw5/rEKzWBCHNS8FvXHPvXvnacTZ5LZRK0ssshECgYEA3xGQ'
          'nDlmRwyVto/1DQMLnjIMazQ719qtCO/pf4BHeqcDYnIwYb5zLBj2nPV8D9pqM1pG'
          'OVuOgcC9IimrbHeeGwp1iSTH4AvxDIj6Iyrmbz2db3lGdHVk9xLvTiYzn2KK2sYx'
          'mFl3DRBFutFQ2YxddqHbE3Ds96Y/uRXhqj7I16cCgYEA1AVNwHM+i1OS3yZtUUH6'
          'xPnySWu9x/RTvpSDwnYKk8TLaHDH0Y//6y3Y7RqK6Utjmv1E+54/0d/B3imyrsG/'
          'wWrj+SQdPO9VJ/is8XZQapnU4cs7Q19b+AhqJq58un2n+1e81J0oGPC47X3BHZTc'
          '5VSyMpvwiqu0WmTMQT37cCECgYACMEbt8XY6bjotz13FIemERNNwXdPUe1XFR61P'
          'ze9lmavj1GD7JIY2wYvx4Eq2URtHo7QarfZI+Z4hbq065DWN6F1c2hqH7TYRPGrP'
          '24TlRIJ97H+vdtNlxS7J4oARKUNZgCZOa1pKq4UznwgfCkyEdHQUzb/VcjEf3MIZ'
          'DIKl8wKBgBrsIjiDvpkfnpmQ7fehEJIi+V4SGskLxFH3ZTvngFFoYry3dL5gQ6mF'
          'sDfrn4igIcEy6bMpJQ3lbwStyzcWZLMJgdI23FTlPXTEG7PclZSuxBpQpvg3MiVO'
          'zqVTrhnY+TemcScSx5O6f32aDfOUWWCzmw/gzvJxUYlJqjqd7dlT'
          '-----END RSA PRIVATE KEY-----'
      ==
    =/  kpem3-pub=wain
      :~  '-----BEGIN RSA PUBLIC KEY-----'
          'MIIBCgKCAQEA2jJp8dgAKy5cSzDE4D+aUbKZsQoMhIWI2IFlE+AO0GCBMig5qxx2'
          'IIAPVIcSi5fjOLtTHnuIZYw+s06qeb8QIKRvkZaIwnA3Lz5UUrxgh96sezdXCCSG'
          '7FndIFskcT+zG00JL+fPRdlPjt1Vg2b3kneo5aAKMIPyOTzcY590UTc+luQ3HhgS'
          'iNF3n5YQh24d3kS2YOUoSXQ13+YRljxNfBgXbV+C7/gO8mFxpkafhmgkIGNeWlqT'
          '9oAIRa+gOx13uPAg+Jb/8lPV9bGaFqGvxvBMp3xUASlzYHiDntcB5MiOPRW6BoIG'
          'I5qDFSYRZBky9crE7WAYgqtPtg21zvxwFwIDAQAB'
          '-----END RSA PUBLIC KEY-----'
      ==
    =/  k3=key:rsa
      (need (ring:de:pem:pkcs1 kpem3))
    =/  k3-pub=key:rsa
      (need (pass:de:pem:pkcs1 kpem3-pub))
    ;:  weld
      %-  expect-eq  !>
        [kpem1 (ring:en:pem:pkcs1 k1)]
      %-  expect-eq  !>
        [k1 (need (ring:de:pem:pkcs1 kpem1))]
      %-  expect-eq  !>
        [kpem2 (ring:en:pem:pkcs1 k2)]
      %-  expect-eq  !>
        [k2 (need (ring:de:pem:pkcs1 kpem2))]
      %-  expect-eq  !>
        [kpem3 (ring:en:pem:pkcs1 k3)]
      %-  expect-eq  !>
        [kpem3-pub (pass:en:pem:pkcs1 k3)]
      %-  expect-eq  !>
        [k3-pub [pub.k3 ~]]
    ==
  ::
  ++  test-rsa-pkcs8
    =/  kpem=wain
      :~  '-----BEGIN RSA PRIVATE KEY-----'
          'MIIEowIBAAKCAQEA2jJp8dgAKy5cSzDE4D+aUbKZsQoMhIWI2IFlE+AO0GCBMig5'
          'qxx2IIAPVIcSi5fjOLtTHnuIZYw+s06qeb8QIKRvkZaIwnA3Lz5UUrxgh96sezdX'
          'CCSG7FndIFskcT+zG00JL+fPRdlPjt1Vg2b3kneo5aAKMIPyOTzcY590UTc+luQ3'
          'HhgSiNF3n5YQh24d3kS2YOUoSXQ13+YRljxNfBgXbV+C7/gO8mFxpkafhmgkIGNe'
          'WlqT9oAIRa+gOx13uPAg+Jb/8lPV9bGaFqGvxvBMp3xUASlzYHiDntcB5MiOPRW6'
          'BoIGI5qDFSYRZBky9crE7WAYgqtPtg21zvxwFwIDAQABAoIBAH0q7GGisj4TIziy'
          '6k1lzwXMuaO4iwO+gokIeU5UessIgTSfpK1G73CnZaPstDPF1r/lncHfxZfTQuij'
          'WOHsO7kt+x5+R0ebDd0ZGVA45fsrPrCUR2XRZmDRECuOfTJGA13G7F1B0kJUbfIb'
          'gAGYIK8x236WNyIrntk804SGpTgstCsZ51rK5GL6diZVQbeU806oP1Zhx/ye//NR'
          'mS5G0iil//H41pV5WGomOX0mq9/HYBZqCncqzLki6FFdmXykjz8snvXUR40S8B+a'
          '0F/LN+549PSe2dp9h0Hx4HCJOsL9CyCQimqqqE8KPQ4BUz8q3+Mhx1xEyaxIlNH9'
          'ECgo1CECgYEA+mi7vQRzstYJerbhCtaeFrOR/n8Dft7FyFN+5IV7H2omy6gf0zr1'
          'GWjmph5R0sMPgL8uVRGANUrkuZZuCr35iY6zQpdCFB4D9t+zbTvTmrxt2oVaE16/'
          'dIJ6b8cHzR2QrEh8uw5/rEKzWBCHNS8FvXHPvXvnacTZ5LZRK0ssshECgYEA3xGQ'
          'nDlmRwyVto/1DQMLnjIMazQ719qtCO/pf4BHeqcDYnIwYb5zLBj2nPV8D9pqM1pG'
          'OVuOgcC9IimrbHeeGwp1iSTH4AvxDIj6Iyrmbz2db3lGdHVk9xLvTiYzn2KK2sYx'
          'mFl3DRBFutFQ2YxddqHbE3Ds96Y/uRXhqj7I16cCgYEA1AVNwHM+i1OS3yZtUUH6'
          'xPnySWu9x/RTvpSDwnYKk8TLaHDH0Y//6y3Y7RqK6Utjmv1E+54/0d/B3imyrsG/'
          'wWrj+SQdPO9VJ/is8XZQapnU4cs7Q19b+AhqJq58un2n+1e81J0oGPC47X3BHZTc'
          '5VSyMpvwiqu0WmTMQT37cCECgYACMEbt8XY6bjotz13FIemERNNwXdPUe1XFR61P'
          'ze9lmavj1GD7JIY2wYvx4Eq2URtHo7QarfZI+Z4hbq065DWN6F1c2hqH7TYRPGrP'
          '24TlRIJ97H+vdtNlxS7J4oARKUNZgCZOa1pKq4UznwgfCkyEdHQUzb/VcjEf3MIZ'
          'DIKl8wKBgBrsIjiDvpkfnpmQ7fehEJIi+V4SGskLxFH3ZTvngFFoYry3dL5gQ6mF'
          'sDfrn4igIcEy6bMpJQ3lbwStyzcWZLMJgdI23FTlPXTEG7PclZSuxBpQpvg3MiVO'
          'zqVTrhnY+TemcScSx5O6f32aDfOUWWCzmw/gzvJxUYlJqjqd7dlT'
          '-----END RSA PRIVATE KEY-----'
      ==
    =/  pub=wain
      :~  '-----BEGIN PUBLIC KEY-----'
          'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA2jJp8dgAKy5cSzDE4D+a'
          'UbKZsQoMhIWI2IFlE+AO0GCBMig5qxx2IIAPVIcSi5fjOLtTHnuIZYw+s06qeb8Q'
          'IKRvkZaIwnA3Lz5UUrxgh96sezdXCCSG7FndIFskcT+zG00JL+fPRdlPjt1Vg2b3'
          'kneo5aAKMIPyOTzcY590UTc+luQ3HhgSiNF3n5YQh24d3kS2YOUoSXQ13+YRljxN'
          'fBgXbV+C7/gO8mFxpkafhmgkIGNeWlqT9oAIRa+gOx13uPAg+Jb/8lPV9bGaFqGv'
          'xvBMp3xUASlzYHiDntcB5MiOPRW6BoIGI5qDFSYRZBky9crE7WAYgqtPtg21zvxw'
          'FwIDAQAB'
          '-----END PUBLIC KEY-----'
      ==
    =/  pri=wain
      :~  '-----BEGIN PRIVATE KEY-----'
          'MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDaMmnx2AArLlxL'
          'MMTgP5pRspmxCgyEhYjYgWUT4A7QYIEyKDmrHHYggA9UhxKLl+M4u1Mee4hljD6z'
          'Tqp5vxAgpG+RlojCcDcvPlRSvGCH3qx7N1cIJIbsWd0gWyRxP7MbTQkv589F2U+O'
          '3VWDZveSd6jloAowg/I5PNxjn3RRNz6W5DceGBKI0XeflhCHbh3eRLZg5ShJdDXf'
          '5hGWPE18GBdtX4Lv+A7yYXGmRp+GaCQgY15aWpP2gAhFr6A7HXe48CD4lv/yU9X1'
          'sZoWoa/G8EynfFQBKXNgeIOe1wHkyI49FboGggYjmoMVJhFkGTL1ysTtYBiCq0+2'
          'DbXO/HAXAgMBAAECggEAfSrsYaKyPhMjOLLqTWXPBcy5o7iLA76CiQh5TlR6ywiB'
          'NJ+krUbvcKdlo+y0M8XWv+Wdwd/Fl9NC6KNY4ew7uS37Hn5HR5sN3RkZUDjl+ys+'
          'sJRHZdFmYNEQK459MkYDXcbsXUHSQlRt8huAAZggrzHbfpY3Iiue2TzThIalOCy0'
          'KxnnWsrkYvp2JlVBt5TzTqg/VmHH/J7/81GZLkbSKKX/8fjWlXlYaiY5fSar38dg'
          'FmoKdyrMuSLoUV2ZfKSPPyye9dRHjRLwH5rQX8s37nj09J7Z2n2HQfHgcIk6wv0L'
          'IJCKaqqoTwo9DgFTPyrf4yHHXETJrEiU0f0QKCjUIQKBgQD6aLu9BHOy1gl6tuEK'
          '1p4Ws5H+fwN+3sXIU37khXsfaibLqB/TOvUZaOamHlHSww+Avy5VEYA1SuS5lm4K'
          'vfmJjrNCl0IUHgP237NtO9OavG3ahVoTXr90gnpvxwfNHZCsSHy7Dn+sQrNYEIc1'
          'LwW9cc+9e+dpxNnktlErSyyyEQKBgQDfEZCcOWZHDJW2j/UNAwueMgxrNDvX2q0I'
          '7+l/gEd6pwNicjBhvnMsGPac9XwP2mozWkY5W46BwL0iKatsd54bCnWJJMfgC/EM'
          'iPojKuZvPZ1veUZ0dWT3Eu9OJjOfYoraxjGYWXcNEEW60VDZjF12odsTcOz3pj+5'
          'FeGqPsjXpwKBgQDUBU3Acz6LU5LfJm1RQfrE+fJJa73H9FO+lIPCdgqTxMtocMfR'
          'j//rLdjtGorpS2Oa/UT7nj/R38HeKbKuwb/BauP5JB0871Un+KzxdlBqmdThyztD'
          'X1v4CGomrny6faf7V7zUnSgY8LjtfcEdlNzlVLIym/CKq7RaZMxBPftwIQKBgAIw'
          'Ru3xdjpuOi3PXcUh6YRE03Bd09R7VcVHrU/N72WZq+PUYPskhjbBi/HgSrZRG0ej'
          'tBqt9kj5niFurTrkNY3oXVzaGoftNhE8as/bhOVEgn3sf69202XFLsnigBEpQ1mA'
          'Jk5rWkqrhTOfCB8KTIR0dBTNv9VyMR/cwhkMgqXzAoGAGuwiOIO+mR+emZDt96EQ'
          'kiL5XhIayQvEUfdlO+eAUWhivLd0vmBDqYWwN+ufiKAhwTLpsyklDeVvBK3LNxZk'
          'swmB0jbcVOU9dMQbs9yVlK7EGlCm+DcyJU7OpVOuGdj5N6ZxJxLHk7p/fZoN85RZ'
          'YLObD+DO8nFRiUmqOp3t2VM='
          '-----END PRIVATE KEY-----'
      ==
    =/  k=key:rsa
      (need (ring:de:pem:pkcs1 kpem))
    ;:  weld
      %-  expect-eq  !>
        [pub (pass:en:pem:pkcs8 k)]
      %-  expect-eq  !>
        [`k(sek ~) (pass:de:pem:pkcs8 pub)]
      %-  expect-eq  !>
        [pri (ring:en:pem:pkcs8 k)]
      %-  expect-eq  !>
        [`k (ring:de:pem:pkcs8 pri)]
    ==
  ::
  ++  test-rsa-pem-zero
    :: intentional bad values to test significant trailing zeros
    =/  k=key:rsa  [[n=(bex 16) e=(bex 16)] ~]
    :: pkcs1
    =/  kpem=wain
      :~  '-----BEGIN RSA PUBLIC KEY-----'
          'MAoCAwEAAAIDAQAA'
          '-----END RSA PUBLIC KEY-----'
      ==
    :: pkcs8
    =/  kpem2=wain
    :~  '-----BEGIN PUBLIC KEY-----'
        'MB4wDQYJKoZIhvcNAQEBBQADDQAwCgIDAQAAAgMBAAA='
        '-----END PUBLIC KEY-----'
    ==
    ;:  weld
      %-  expect-eq  !>
        [kpem (pass:en:pem:pkcs1 k)]
      %-  expect-eq  !>
        [`k (pass:de:pem:pkcs1 kpem)]
      %-  expect-eq  !>
        [kpem2 (pass:en:pem:pkcs8 k)]
      %-  expect-eq  !>
        [`k (pass:de:pem:pkcs8 kpem2)]
    ==
  ::
  ++  test-rsa
    =/  k1=key:rsa
      =/  p  `@ux`61
      =/  q  `@ux`53
      =/  e  `@ux`17
      =/  n  (mul p q)
      =/  d  (~(inv fo (elcm:rsa (dec p) (dec q))) e)
      [[n e] `[d p q]]
    ::
    =/  k2=key:rsa
      :-  [`@ux`143 `@ux`7]
      [~ `@ux`103 `@ux`11 `@ux`13]
    ::
    :: ex from http://doctrina.org/How-RSA-Works-With-Examples.html
    =/  k3=key:rsa
      =/  p
    12.131.072.439.211.271.897.323.671.531.612.440.428.472.427.633.701.410.
       925.634.549.312.301.964.373.042.085.619.324.197.365.322.416.866.541.
       017.057.361.365.214.171.711.713.797.974.299.334.871.062.829.803.541
      =/  q
    12.027.524.255.478.748.885.956.220.793.734.512.128.733.387.803.682.075.
       433.653.899.983.955.179.850.988.797.899.869.146.900.809.131.611.153.
       346.817.050.832.096.022.160.146.366.346.391.812.470.987.105.415.233
      =/  n  (mul p q)
      =/  e  65.537
      =/  d  (~(inv fo (elcm:rsa (dec p) (dec q))) e)
      [[`@ux`n `@ux`e] `[`@ux`d `@ux`p `@ux`q]]
    =/  m3  (swp 3 'attack at dawn')
    =/  c3
      35.052.111.338.673.026.690.212.423.937.053.328.511.880.760.811.579.981.
         620.642.802.346.685.810.623.109.850.235.943.049.080.973.386.241.113.
         784.040.794.704.193.978.215.378.499.765.413.083.646.438.784.740.952.
         306.932.534.945.195.080.183.861.574.225.226.218.879.827.232.453.912.
         820.596.886.440.377.536.082.465.681.750.074.417.459.151.485.407.445.
         862.511.023.472.235.560.823.053.497.791.518.928.820.272.257.787.786
    ::
    ?>  ?=(^ sek.k1)
    ;:  weld
      %-  expect-eq  !>
        [413 d.u.sek.k1]
      %-  expect-eq  !>
        [2.790 (en:rsa 65 k1)]
      %-  expect-eq  !>
        [65 (de:rsa 2.790 k1)]
      ::
      %-  expect-eq  !>
        [48 (en:rsa 9 k2)]
      %-  expect-eq  !>
        [9 (de:rsa 48 k2)]
      ::
      %-  expect-eq  !>
        [c3 (en:rsa m3 k3)]
      %-  expect-eq  !>
        [m3 (de:rsa c3 k3)]
    ==
  ::
  ++  test-rs256
    ::  ex from https://stackoverflow.com/a/41448118
    =/  k1=key:rsa
      :*  :-  n=0xc231.1fc5.fa31.d333.a409.bb4c.e95b.20d2.1cfc.e375.3871.7256.53a2.
            8425.af6d.e97d.f202.0b23.633f.458d.f12a.6362.7121.bff4.e23c.e578.
            7e07.7898.0578.61d1.ae60.ac2f
          e=0x1.0001
          ~
          d=0xd91.6719.eb10.3e24.768a.a386.8d2b.6bd0.a26b.dcec.9cc3.f86c.25ad.
            ce33.dfdc.fb1a.4d50.3e07.3d7f.f5fd.748e.43f8.df02.a60e.d730.5314.
            3e59.1e70.8df7.2c27.93e2.2b69
          p=0xf7ef.37e6.7fa6.685a.c178.8b01.cf38.da20.ca4b.de5d.8b01.a71b.d28c.
            65b4.09c3.6e4d
          q=0xc882.5760.3fb8.a5e2.5e9d.db55.3a73.b647.a3ec.a6e9.abc6.c440.dbc7.
            05f8.2ed4.da6b
      ==
    =/  inp1  0x302.0101
    =/  exp1
      0x575c.8a41.09ed.6ea2.a708.6338.d150.a5bb.8205.142e.7785.47b5.0cc6.0198.
        6807.0243.bf49.de7c.6039.0160.e392.faca.18f4.a05d.3a7a.88a4.de86.dd99.
        f030.eb4a.a755.d7ce
    =/  emsa1
      0x1.ffff.ffff.ffff.ffff.ffff.0030.3130.0d06.0960.8648.0165.0304.0201.0500.
          0420.9184.abd2.bb31.8731.d717.e972.0572.40ea.e26c.ca20.2a8d.35db.e9d2.
          176f.5268.86a0
    =/  kpem2=wain
      :~  '-----BEGIN RSA PRIVATE KEY-----'
          'MIIEowIBAAKCAQEA2jJp8dgAKy5cSzDE4D+aUbKZsQoMhIWI2IFlE+AO0GCBMig5'
          'qxx2IIAPVIcSi5fjOLtTHnuIZYw+s06qeb8QIKRvkZaIwnA3Lz5UUrxgh96sezdX'
          'CCSG7FndIFskcT+zG00JL+fPRdlPjt1Vg2b3kneo5aAKMIPyOTzcY590UTc+luQ3'
          'HhgSiNF3n5YQh24d3kS2YOUoSXQ13+YRljxNfBgXbV+C7/gO8mFxpkafhmgkIGNe'
          'WlqT9oAIRa+gOx13uPAg+Jb/8lPV9bGaFqGvxvBMp3xUASlzYHiDntcB5MiOPRW6'
          'BoIGI5qDFSYRZBky9crE7WAYgqtPtg21zvxwFwIDAQABAoIBAH0q7GGisj4TIziy'
          '6k1lzwXMuaO4iwO+gokIeU5UessIgTSfpK1G73CnZaPstDPF1r/lncHfxZfTQuij'
          'WOHsO7kt+x5+R0ebDd0ZGVA45fsrPrCUR2XRZmDRECuOfTJGA13G7F1B0kJUbfIb'
          'gAGYIK8x236WNyIrntk804SGpTgstCsZ51rK5GL6diZVQbeU806oP1Zhx/ye//NR'
          'mS5G0iil//H41pV5WGomOX0mq9/HYBZqCncqzLki6FFdmXykjz8snvXUR40S8B+a'
          '0F/LN+549PSe2dp9h0Hx4HCJOsL9CyCQimqqqE8KPQ4BUz8q3+Mhx1xEyaxIlNH9'
          'ECgo1CECgYEA+mi7vQRzstYJerbhCtaeFrOR/n8Dft7FyFN+5IV7H2omy6gf0zr1'
          'GWjmph5R0sMPgL8uVRGANUrkuZZuCr35iY6zQpdCFB4D9t+zbTvTmrxt2oVaE16/'
          'dIJ6b8cHzR2QrEh8uw5/rEKzWBCHNS8FvXHPvXvnacTZ5LZRK0ssshECgYEA3xGQ'
          'nDlmRwyVto/1DQMLnjIMazQ719qtCO/pf4BHeqcDYnIwYb5zLBj2nPV8D9pqM1pG'
          'OVuOgcC9IimrbHeeGwp1iSTH4AvxDIj6Iyrmbz2db3lGdHVk9xLvTiYzn2KK2sYx'
          'mFl3DRBFutFQ2YxddqHbE3Ds96Y/uRXhqj7I16cCgYEA1AVNwHM+i1OS3yZtUUH6'
          'xPnySWu9x/RTvpSDwnYKk8TLaHDH0Y//6y3Y7RqK6Utjmv1E+54/0d/B3imyrsG/'
          'wWrj+SQdPO9VJ/is8XZQapnU4cs7Q19b+AhqJq58un2n+1e81J0oGPC47X3BHZTc'
          '5VSyMpvwiqu0WmTMQT37cCECgYACMEbt8XY6bjotz13FIemERNNwXdPUe1XFR61P'
          'ze9lmavj1GD7JIY2wYvx4Eq2URtHo7QarfZI+Z4hbq065DWN6F1c2hqH7TYRPGrP'
          '24TlRIJ97H+vdtNlxS7J4oARKUNZgCZOa1pKq4UznwgfCkyEdHQUzb/VcjEf3MIZ'
          'DIKl8wKBgBrsIjiDvpkfnpmQ7fehEJIi+V4SGskLxFH3ZTvngFFoYry3dL5gQ6mF'
          'sDfrn4igIcEy6bMpJQ3lbwStyzcWZLMJgdI23FTlPXTEG7PclZSuxBpQpvg3MiVO'
          'zqVTrhnY+TemcScSx5O6f32aDfOUWWCzmw/gzvJxUYlJqjqd7dlT'
          '-----END RSA PRIVATE KEY-----'
      ==
    =/  k2=key:rsa
      (need (ring:de:pem:pkcs1 kpem2))
    =/  inp2=cord  'hello\0a'
    =/  exp2=@ux
      0x2920.bba3.cb38.bca6.3768.6345.c95e.0717.81bf.6c61.4006.6070.a7b5.e609.
        f3b4.7f48.878b.d1f8.1882.8852.1db6.b6b5.a5fd.c23b.e764.b910.5a3f.fda9.
        9d3a.e8bd.060a.ac06.58f1.487a.b50d.dee2.e161.0b74.4d3b.e6e3.7004.c721.
        4f32.5c95.ce68.a008.b1e9.788b.375f.d389.0fa4.4012.c07a.8319.a183.02d5.
        e2b8.10df.6ff7.f64a.6b85.3c7d.de80.19cf.ab6d.e588.40cb.0ea4.c436.8d8b.
        47f7.cce6.b9bf.097d.3275.c128.147a.628d.2b7c.3912.3950.ef68.87b2.180d.
        ba01.3b05.285d.3dfd.09ee.2f38.3111.9e4c.92c6.bf66.a91b.5762.3cdf.f8b7.
        8281.81a2.8324.5330.43c1.035a.56c3.71b8.eb85.e660.c3a4.28b4.8af7.c16f.
        7d7d.87cc.036d.aeb2.c757.30f5.f194.c90d.6bb4.5e5c.f95f.8e28.0fbc.5fb4.
        b21a.e6fe
    =/  exp2b64=cord
      %+  rap  3
      :~  'KSC7o8s4vKY3aGNFyV4HF4G/bGFABmBwp7XmCfO0f0iHi9H4GIKIUh22trWl/cI752S5'
          'EFo//amdOui9BgqsBljxSHq1Dd7i4WELdE075uNwBMchTzJclc5ooAix6XiLN1/TiQ+k'
          'QBLAeoMZoYMC1eK4EN9v9/ZKa4U8fd6AGc+rbeWIQMsOpMQ2jYtH98zmub8JfTJ1wSgU'
          'emKNK3w5EjlQ72iHshgNugE7BShdPf0J7i84MRGeTJLGv2apG1diPN/4t4KBgaKDJFMw'
          'Q8EDWlbDcbjrheZgw6QotIr3wW99fYfMA22ussdXMPXxlMkNa7ReXPlfjigPvF+0shrm'
          '/g=='
      ==
    =/  sig=@ux  (~(sign rs256 k2) inp2)
    ;:  weld
      %-  expect-eq  !>
        [exp1 (~(sign rs256 k1) inp1)]
      %-  expect-eq  !>
        [& (~(verify rs256 k1) exp1 inp1)]
      %-  expect-eq  !>
        [emsa1 `@ux`(~(emsa rs256 k1) inp1)]
      %-  expect-eq  !>
        [& (~(verify rs256 k2) sig inp2)]
      %-  expect-eq  !>
        [exp2 sig]
      :: save kpem2 to private.pem
      :: echo "hello" | openssl dgst -sha256 -sign private.pem | base64
      %-  expect-eq  !>
        [exp2b64 (en:base64 (met 3 sig) (swp 3 sig))]
    ==
  ::
  ++  test-jwk
    :: rfc7638 section 3.1
    =/  n
      :~  '0vx7agoebGcQSuuPiLJXZptN9nndrQmbXEps2'
          'aiAFbWhM78LhWx4cbbfAAtVT86zwu1RK7aPFFxuhDR1L6tSoc_BJECPebWKRXjBZCi'
          'FV4n3oknjhMstn64tZ_2W-5JsGY4Hc5n9yBXArwl93lqt7_RN5w6Cf0h4QyQ5v-65Y'
          'GjQR0_FDW2QvzqY368QQMicAtaSqzs8KJZgnYb9c7d0zgdAZHzu6qMQvRL5hajrn1n'
          '91CbOpbISD08qNLyrdkt-bFTWhAI4vMQFh6WeZu0fM4lFd2NcRwr3XPksINHaQ-G_x'
          'BniIqbw0Ls1jF44-csFCur-kEgU8awapJzKnqDKgw'
      ==
    =/  jk=json
      :-  %o  %-  my  :~
        kty+s+'RSA'
        n+s+(rap 3 n)
        e+s+'AQAB'
      ==
    =/  k  (need (pass:de:jwk jk))
    ;:  weld
      %-  expect-eq  !>
        :-  jk
        (pass:en:jwk k)
      %-  expect-eq  !>
        :-  'NzbLsXh8uDCcd-6MNwXF4W_7noWXFZAfHkxZsRGC9Xs'
        (pass:thumb:jwk k)
    ==
  ::
  ++  test-jws
    ::  rfc7515 appendix 2
    =/  pt=@t
      %+  rap  3
      :~  '4BzEEOtIpmVdVEZNCqS7baC4crd0pqnRH_5IB3jw3bcxGn6QLvnEtfdUdi'
          'YrqBdss1l58BQ3KhooKeQTa9AB0Hw_Py5PJdTJNPY8cQn7ouZ2KKDcmnPG'
          'BY5t7yLc1QlQ5xHdwW1VhvKn-nXqhJTBgIPgtldC-KDV5z-y2XDwGUc'
      ==
    =/  qt=@t
      %+  rap  3
      :~  'uQPEfgmVtjL0Uyyx88GZFF1fOunH3-7cepKmtH4pxhtCoHqpWmT8YAmZxa'
          'ewHgHAjLYsp1ZSe7zFYHj7C6ul7TjeLQeZD_YwD66t62wDmpe_HlB-TnBA'
          '-njbglfIsRLtXlnDzQkv5dTltRJ11BKBBypeeF6689rjcJIDEz9RWdc'
      ==
    =/  nt=@t
      %+  rap  3
      :~  'ofgWCuLjybRlzo0tZWJjNiuSfb4p4fAkd_wWJcyQoTbji9k0l8W26mPddx'
          'HmfHQp-Vaw-4qPCJrcS2mJPMEzP1Pt0Bm4d4QlL-yRT-SFd2lZS-pCgNMs'
          'D1W_YpRPEwOWvG6b32690r2jZ47soMZo9wGzjb_7OMg0LOL-bSf63kpaSH'
          'SXndS5z5rexMdbBYUsLA9e-KXBdQOS-UTo7WTBEMa2R2CapHg665xsmtdV'
          'MTBQY4uDZlxvb3qCo5ZwKh9kG4LT6_I5IhlJH7aGhyxXFvUK-DWNmoudF8'
          'NAco9_h9iaGNj8q2ethFkMLs91kzk2PAcDTW9gb54h4FRWyuXpoQ'
       ==
    =/  dt=@t
      %+  rap  3
      :~  'Eq5xpGnNCivDflJsRQBXHx1hdR1k6Ulwe2JZD50LpXyWPEAeP88vLNO97I'
          'jlA7_GQ5sLKMgvfTeXZx9SE-7YwVol2NXOoAJe46sui395IW_GO-pWJ1O0'
          'BkTGoVEn2bKVRUCgu-GjBVaYLU6f3l9kJfFNS3E0QbVdxzubSu3Mkqzjkn'
          '439X0M_V51gfpRLI9JYanrC4D4qAdGcopV_0ZHHzQlBjudU2QvXt4ehNYT'
          'CBr6XCLQUShb1juUO1ZdiYoFaFQT5Tw8bGUl_x_jTj3ccPDVZFD9pIuhLh'
          'BOneufuBiB4cS98l2SR_RQyGWSeWjnczT0QU91p1DhOVRuOopznQ'
      ==
    =/  jk=json
      :-  %o  %-  my  :~
        kty+s+'RSA'
        n+s+nt
        e+s+'AQAB'
        d+s+dt
        p+s+pt
        q+s+qt
      ==
    =/  k=key:rsa  (need (ring:de:jwk jk))
    =/  hed=json  o+(my alg+s+'RS256' ~)
    =/  hedt=@t  'eyJhbGciOiJSUzI1NiJ9'
    =/  lod=json
      :-  %o  %-  my  :~
        iss+s+'joe'
        exp+n+'1300819380'
        ['http://example.com/is_root' %b &]
      ==
    =/  lodt=@t
      %+  rap  3
      :~  'eyJpc3MiOiJqb2UiLCJleHAiOjEzMDA4MTkzODAsImh0dHA'
          '6Ly9leGFtcGxlLmNvbS9pc19yb290Ijp0cnVlfQ'
      ==
    ::  rfc example includes whitespace in json serialization
    =/  lodt-ws=@t
      %+  rap  3
      :~  'eyJpc3MiOiJqb2UiLA0KICJleHAiOjEzMDA4MTkzODAsDQo'
          'gImh0dHA6Ly9leGFtcGxlLmNvbS9pc19yb290Ijp0cnVlfQ'
      ==
    =/  inp-ws=@t
      (rap 3 [hedt '.' lodt-ws ~])
    =/  exp-ws=@t
      %+  rap  3
      :~  'cC4hiUPoj9Eetdgtv3hF80EGrhuB__dzERat0XF9g2VtQgr9PJbu3XOiZj5RZmh7'
          'AAuHIm4Bh-0Qc_lF5YKt_O8W2Fp5jujGbds9uJdbF9CUAr7t1dnZcAcQjbKBYNX4'
          'BAynRFdiuB--f_nZLgrnbyTyWzO75vRK5h6xBArLIARNPvkSjtQBMHlb1L07Qe7K'
          '0GarZRmB_eSN9383LcOLn6_dO--xi12jzDwusC-eOkHWEsqtFZESc6BfI7noOPqv'
          'hJ1phCnvWh6IeYI2w9QOYEUipUTI8np6LbgGY9Fs98rqVt5AXLIhWkWywlVmtVrB'
          'p0igcN_IoypGlUPQGe77Rw'
      ==
    =/  lod-order=(list @t)  ['iss' 'exp' 'http://example.com/is_root' ~]
    ?>  ?=(^ sek.k)
    ;:  weld
      %-  expect-eq  !>
        [jk (ring:en:jwk k)]
      %-  expect-eq  !>
        [n.pub.k `@ux`(mul p.u.sek.k q.u.sek.k)]
      %-  expect-eq  !>
        :-  d.u.sek.k
        `@ux`(~(inv fo (elcm:rsa (dec p.u.sek.k) (dec q.u.sek.k))) e.pub.k)
      %-  expect-eq  !>
        :-  hedt
        (en-base64url (as-octt:mimes:html (en-json-sort aor hed)))
      %-  expect-eq  !>
        :-  lodt
        (en-base64url (as-octt:mimes:html (en-json-sort (eor lte lod-order) lod)))
      %-  expect-eq  !>
        :-  exp-ws
        (en-base64url (en:octn (~(sign rs256 k) inp-ws)))
    ==
  ::
  ++  test-jws-2
    :: captured from an in-the-wild failure
    :: relevant sha-256 has a significant leading zero
    :: which was not being captured in the asn.1 digest ...
    =/  kpem=wain
      :~  '-----BEGIN RSA PRIVATE KEY-----'
          'MIIEogIBAAKCAQEAkmWLu+9gyzCbrGAHTFE6Hs7CtVQofONmpnhmE7JQkmdS+aph'
          'WwZQfp9p6RU6vSoBaPXD96uqMXhvoOXz9/Ub5TRwLmQzfHZdksfU3pEZ8qFMikZU'
          'p5v+CyBnLq9YR0VXN+/JVatmYb1hhC1k101X9m+IU3DR3U+kyCZnXuOd10xVX05H'
          '0pXl+nI25bZyMJFnz1Xfw1rTnhtU/w7bgCWYdMii5jLkl5zfoY2gulpPu7QeYa4K'
          '3fTqklDNFK7kQQ1l4O3461fbSO0cnG4t8Vk3026ageA54+Qx8O8UDi8k18Z1NF+B'
          'pbPUZn55/InuZ8iGyHBZ4GRFIPG0iOdWM7gHCwIDAQABAoIBAAMQN/9SS6MJMULq'
          'CsXHxyl5sHtXa/BgWLHP+j2/FtRX++EkR0s+ln2FobZa+l5Q9m4Ljn5PbqSMAFfM'
          'Y6u0hNyj9om04oOl8bILl4Vcvqgp51oFvAEGOW15/o69+6bS3aBx7cqwfnsivInr'
          'nIXDvHcyey3kh9WCKNx3rxNVgfuTCkw0+K2qXkMTh2c3Iz2efR2f78qbNWQcBe1+'
          's83fABafxACYuXzfOYoO01GBCJnHrmXxJVePLXwxLkLeJHOQJQgPnagVbUH4kbUp'
          'OLd9h1dOVYKpyVaxbQiAH3U/ekOXCCv18a47/PQSbueolzSzMzwVPSZdf+88lzuq'
          'ZZyDXDECgYEAk5zt4cO7X+8IIeNXx8/2pztT9WmC1kqw4RtInoVXm62K1B0pPndW'
          'm0nMVFEDuSwdn61G5amlaOT0dTFHlMFydC9H+1L5PMK7d+6ArSeAtMWoUhz+jkcO'
          'B9KoMfZ9CtP2r5589zDGir8kaY8Fia5Z7TohpJDidmuumgDabl+qH+kCgYEA/eP6'
          'lIGVHF8EIrfewjLM+8i1RE/hzItOpegrwDUVeYfZlPM59xUyC9REdgvmnTssxPcL'
          '2+EB11wvcImSPLuwN0kXUkh9qZUkr9hvYlikALNH1f8WhCJ0kT6pUeA7LbjU4/bM'
          'fsgcOh1POW2piIMERl1TuNRZg7JdKuCJKax3qtMCgYB2dxcifOc/0qIAMGgeX/Rf'
          'ueljp03tlPvnbPIW5oSs19X27YBQNY44Cj4F3Q7T6WfM4k9nuYKacEUQWIBODgJA'
          '5EEsniaQcOfrFGoIjQ9qBMdVPxe8L6I+/P0nO96Wdg4gW12HNIniiAw8+x9Co75f'
          '+KtPW0ekKj9yMQUcV4I9IQKBgE06bruDmzbRFDH3WjQaPc4M5E6OOfH9IgRHVh+W'
          'Rhz8nMu5HJWzBdEhVV3PCuwi1uBnAV112RiIOwnxXuFIejam7ggics8Fxe4TWPZC'
          'Xki0QBKxEElLLcgMlnaITZf/1AovxU5/Uk6/IZ0nZV1X9RHuS4w6U6xCsiJbwH1D'
          'r/bvAoGAV/Vx+Z2BD7QhmHofu98OMW6EGSjWMgOI4iXdcQ80Urz9akHkOM4KGojq'
          'UDobbxxkJt1K5Dzux+vnp1siiIkcLdVdtMzqo7KcKYWonMqZmppNqIFCXQHscCRD'
          'r6f1TIjlurYrazLAkRsmjE5uYM13/E1UdxplWSkdCbivIWqoqTM='
          '-----END RSA PRIVATE KEY-----'
      ==
    =/  k=key:rsa
      (need (ring:de:pem:pkcs1 kpem))
    =/  kid=@t
      'https://acme-staging-v02.api.letsencrypt.org/acme/acct/6336694'
    =/  non=@t
      'a5Pwh6GcuqRSvHTQouW96XNg3iiMORMkBf_wSLOf0M4'
    =/  url=purl
      :-  [sec=%.y por=~ hot=[%.y p=/org/letsencrypt/api/acme-staging-v02]]
      :_  query=~
      :-  ext=~
      %+  weld
        /acme/challenge
      /'efJn0ywfjIi3M7yT-6H8Mdq85R2LnI8XsTG3DaaY8Gc'/'138087558'
    =/  protected-header=json
      :-  %o  %-  my  :~
        nonce+s+non
        url+s+(crip (en-purl:html url))
        kid+s+kid
      ==
    =/  bod=json
      [%o ~]
    =/  exp=json
      =/  payload=@t  'e30'
      =/  protected=@t
        %+  rap  3
        :~  'eyJhbGci'
            'OiJSUzI1NiIsImtpZCI6Imh0dHBzOi8vYWNtZS1zdGFnaW5nLXYwMi5hcGkubGV0c2'
            'VuY3J5cHQub3JnL2FjbWUvYWNjdC82MzM2Njk0Iiwibm9uY2UiOiJhNVB3aDZHY3Vx'
            'UlN2SFRRb3VXOTZYTmczaWlNT1JNa0JmX3dTTE9mME00IiwidXJsIjoiaHR0cHM6Ly'
            '9hY21lLXN0YWdpbmctdjAyLmFwaS5sZXRzZW5jcnlwdC5vcmcvYWNtZS9jaGFsbGVu'
            'Z2UvZWZKbjB5d2ZqSWkzTTd5VC02SDhNZHE4NVIyTG5JOFhzVEczRGFhWThHYy8xMz'
            'gwODc1NTgifQ'
        ==
      =/  signature=@t
        %+  rap  3
        :~  'cukOS_KIWTolvORyJoIu5eejdLoFi6xpd06Y6nW565zFMKZi44BepsWIZXw4yxYjxs'
            '8xFdoKOxtXhBS5BT0mbkHSUGokAPTUiF5b1wjm00ZiKRYwnIotizsLPzHAJKwhMlFs'
            'x6oAu25mmremBgnNtVD_cskQBbkTBgiTL6alrkrmwxlP2gSqyX6uEO-UCY71QB_xYj'
            '4IOoX2k0jdXJevXDAJSUWfs5cZkm8Ug_q4GVTRWhZmFHMnMzonmCC4Ui7nDa9oKJH5'
            'Npyn74FCcqbz111AK-Aul1dNhz3ojE1VOk3eVjH69lSGsaMleYR5fi60Jdc5ZbpPPy'
            't-CZRp1F0k6w'
        ==
      [%o (my payload+s+payload protected+s+protected signature+s+signature ~)]
    %-  expect-eq  !>
      :-  exp
      (sign:jws k protected-header bod)
  ::
  ++  test-csr
    =/  kpem=wain
      :~  '-----BEGIN RSA PRIVATE KEY-----'
          'MIIEowIBAAKCAQEA2jJp8dgAKy5cSzDE4D+aUbKZsQoMhIWI2IFlE+AO0GCBMig5'
          'qxx2IIAPVIcSi5fjOLtTHnuIZYw+s06qeb8QIKRvkZaIwnA3Lz5UUrxgh96sezdX'
          'CCSG7FndIFskcT+zG00JL+fPRdlPjt1Vg2b3kneo5aAKMIPyOTzcY590UTc+luQ3'
          'HhgSiNF3n5YQh24d3kS2YOUoSXQ13+YRljxNfBgXbV+C7/gO8mFxpkafhmgkIGNe'
          'WlqT9oAIRa+gOx13uPAg+Jb/8lPV9bGaFqGvxvBMp3xUASlzYHiDntcB5MiOPRW6'
          'BoIGI5qDFSYRZBky9crE7WAYgqtPtg21zvxwFwIDAQABAoIBAH0q7GGisj4TIziy'
          '6k1lzwXMuaO4iwO+gokIeU5UessIgTSfpK1G73CnZaPstDPF1r/lncHfxZfTQuij'
          'WOHsO7kt+x5+R0ebDd0ZGVA45fsrPrCUR2XRZmDRECuOfTJGA13G7F1B0kJUbfIb'
          'gAGYIK8x236WNyIrntk804SGpTgstCsZ51rK5GL6diZVQbeU806oP1Zhx/ye//NR'
          'mS5G0iil//H41pV5WGomOX0mq9/HYBZqCncqzLki6FFdmXykjz8snvXUR40S8B+a'
          '0F/LN+549PSe2dp9h0Hx4HCJOsL9CyCQimqqqE8KPQ4BUz8q3+Mhx1xEyaxIlNH9'
          'ECgo1CECgYEA+mi7vQRzstYJerbhCtaeFrOR/n8Dft7FyFN+5IV7H2omy6gf0zr1'
          'GWjmph5R0sMPgL8uVRGANUrkuZZuCr35iY6zQpdCFB4D9t+zbTvTmrxt2oVaE16/'
          'dIJ6b8cHzR2QrEh8uw5/rEKzWBCHNS8FvXHPvXvnacTZ5LZRK0ssshECgYEA3xGQ'
          'nDlmRwyVto/1DQMLnjIMazQ719qtCO/pf4BHeqcDYnIwYb5zLBj2nPV8D9pqM1pG'
          'OVuOgcC9IimrbHeeGwp1iSTH4AvxDIj6Iyrmbz2db3lGdHVk9xLvTiYzn2KK2sYx'
          'mFl3DRBFutFQ2YxddqHbE3Ds96Y/uRXhqj7I16cCgYEA1AVNwHM+i1OS3yZtUUH6'
          'xPnySWu9x/RTvpSDwnYKk8TLaHDH0Y//6y3Y7RqK6Utjmv1E+54/0d/B3imyrsG/'
          'wWrj+SQdPO9VJ/is8XZQapnU4cs7Q19b+AhqJq58un2n+1e81J0oGPC47X3BHZTc'
          '5VSyMpvwiqu0WmTMQT37cCECgYACMEbt8XY6bjotz13FIemERNNwXdPUe1XFR61P'
          'ze9lmavj1GD7JIY2wYvx4Eq2URtHo7QarfZI+Z4hbq065DWN6F1c2hqH7TYRPGrP'
          '24TlRIJ97H+vdtNlxS7J4oARKUNZgCZOa1pKq4UznwgfCkyEdHQUzb/VcjEf3MIZ'
          'DIKl8wKBgBrsIjiDvpkfnpmQ7fehEJIi+V4SGskLxFH3ZTvngFFoYry3dL5gQ6mF'
          'sDfrn4igIcEy6bMpJQ3lbwStyzcWZLMJgdI23FTlPXTEG7PclZSuxBpQpvg3MiVO'
          'zqVTrhnY+TemcScSx5O6f32aDfOUWWCzmw/gzvJxUYlJqjqd7dlT'
          '-----END RSA PRIVATE KEY-----'
      ==
    =/  k=key:rsa
      (need (ring:de:pem:pkcs1 kpem))
    ::  generated with openssl, certbot style
    =/  csr-pem=wain
      :~  '-----BEGIN CERTIFICATE REQUEST-----'
          'MIICezCCAWMCAQAwADCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANoy'
          'afHYACsuXEswxOA/mlGymbEKDISFiNiBZRPgDtBggTIoOascdiCAD1SHEouX4zi7'
          'Ux57iGWMPrNOqnm/ECCkb5GWiMJwNy8+VFK8YIferHs3VwgkhuxZ3SBbJHE/sxtN'
          'CS/nz0XZT47dVYNm95J3qOWgCjCD8jk83GOfdFE3PpbkNx4YEojRd5+WEIduHd5E'
          'tmDlKEl0Nd/mEZY8TXwYF21fgu/4DvJhcaZGn4ZoJCBjXlpak/aACEWvoDsdd7jw'
          'IPiW//JT1fWxmhahr8bwTKd8VAEpc2B4g57XAeTIjj0VugaCBiOagxUmEWQZMvXK'
          'xO1gGIKrT7YNtc78cBcCAwEAAaA2MDQGCSqGSIb3DQEJDjEnMCUwIwYDVR0RBBww'
          'GoINem9kLnVyYml0Lm9yZ4IJem9kLnVyYml0MA0GCSqGSIb3DQEBCwUAA4IBAQCu'
          'HdUqIlW8w7G7l3YxXfb0fn1HxD7zHf3QpNqDYZuDq958OhJNXYJ9EjiHBBEW5ySg'
          'e7vyaaWh6UcVIu/RYFGbyVupNVbp4aS4U1LEEiqMQ6vQQnlSt7hVMi04bhf6X6jd'
          'kkTJIB5OlmNh5z/mjvlIOyOCeitK5IMrStsUPE5F8OynMuzmBKq318LiwImO41Fu'
          'S1M6rgPnvoZeqShLxnJduMcu7awHQ0tn2FmjwBpU713/tmNjtCLYYoBxsHM2ptxd'
          'G3zcMSCDZ/CLXWoktkULdWNDED8meCKWQJxYuHjxY4JPIzIVdVN50xRcZEV7Z80l'
          'bPcFaE8op3e2hIxzqi1t'
          '-----END CERTIFICATE REQUEST-----'
      ==
    =/  hot1  /org/urbit/zod
    =/  hot2  /urbit/zod
    %-  expect-eq  !>
      :-  csr-pem
      (en:pem:pkcs10 k [hot1 hot2 ~])
  --
--
