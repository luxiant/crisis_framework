"""주석과 docstring 을 지운 사본을 임시 디렉터리에 세운다. 뒤의 세 단계가 그 사본을 읽는다.

`scripts/verify.sh` 의 `step3-forbidden` 단계가 이 모듈을 부르고 그 산출을 받는다.
"""

from vstep_common import strip
import os
def run(dest, files) -> None:
    """주석과 docstring 을 지운 사본을 `dest` 아래에 세운다."""
    for f in files:
        p = os.path.join(dest, f)
        os.makedirs(os.path.dirname(p), exist_ok=True)
        with open(p, 'w', encoding='utf-8') as out:
            out.write(strip(open(f, encoding='utf-8').read()))
