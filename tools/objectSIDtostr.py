import sys
import struct
import binascii

if len(sys.argv) != 2:
    print(f"Usage:\n\t{sys.argv[0]} <sid_hex_blob>", file=sys.stderr)
    print("\nDescription:"
        "\n\tSometimes you need deal with WMI or ldapsearch and end up with objectSID blobs,"
        "\n\tusually base64, this script takes the blob as hex and gives you the string SID."
        "\n\tSID. E.g. S-1-48378511622149-21-432542436-3871972811-1783244671-500"
        "\n\tMade by NedX", file=sys.stderr)
    sys.exit(1)

h = sys.argv[1].replace("0x", "")
b = binascii.unhexlify(h)
sid = "S-%d-%d-%s" % (b[0], int.from_bytes(b[2:8], 'big'),
                     '-'.join(str(int.from_bytes(b[8 + i * 4:12 + i * 4], 'little')) for i in range(b[1])))
print(sid)
