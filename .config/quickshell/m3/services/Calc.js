.pragma library
// Tiny safe expression evaluator (no eval). + - * / % ^ ( ), constants pi e, sqrt sin cos tan log ln abs floor ceil round
function evaluate(src) {
    const s = src.toLowerCase()
    let i = 0
    const fns = { sqrt: Math.sqrt, sin: Math.sin, cos: Math.cos, tan: Math.tan, log: Math.log10, ln: Math.log,
                  abs: Math.abs, floor: Math.floor, ceil: Math.ceil, round: Math.round }
    function ws() { while (i < s.length && s[i] === " ") i++ }
    function peek() { ws(); return s[i] }
    function num() {
        ws(); const st = i
        while (i < s.length && /[0-9.]/.test(s[i])) i++
        if (st === i) throw 0
        return parseFloat(s.slice(st, i))
    }
    function ident() { ws(); const st = i; while (i < s.length && /[a-z]/.test(s[i])) i++; return s.slice(st, i) }
    function primary() {
        const c = peek()
        if (c === "(") { i++; const v = expr(); if (peek() !== ")") throw 0; i++; return v }
        if (c !== undefined && /[a-z]/.test(c)) {
            const id = ident()
            if (id === "pi") return Math.PI
            if (id === "e") return Math.E
            const fn = fns[id]
            if (!fn || peek() !== "(") throw 0
            i++; const v = expr(); if (peek() !== ")") throw 0; i++
            return fn(v)
        }
        return num()
    }
    function unary() {
        const c = peek()
        if (c === "-") { i++; return -unary() }
        if (c === "+") { i++; return unary() }
        return primary()
    }
    function power() { const b = unary(); if (peek() === "^") { i++; return Math.pow(b, power()) } return b }
    function term() {
        let v = power()
        for (;;) {
            const c = peek()
            if (c === "*") { i++; v *= power() }
            else if (c === "/") { i++; v /= power() }
            else if (c === "%") { i++; v %= power() }
            else return v
        }
    }
    function expr() {
        let v = term()
        for (;;) {
            const c = peek()
            if (c === "+") { i++; v += term() }
            else if (c === "-") { i++; v -= term() }
            else return v
        }
    }
    try {
        const v = expr(); ws()
        if (i !== s.length || !isFinite(v)) return null
        return v
    } catch (e) { return null }
}
function format(v) { return String(parseFloat(v.toPrecision(12))) }
