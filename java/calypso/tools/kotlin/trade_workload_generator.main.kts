#!/usr/bin/env kotlin

import java.io.File
import kotlin.random.Random

fun argValue(args: Array<String>, name: String, default: String): String {
    val index = args.indexOf(name)
    return if (index >= 0 && index + 1 < args.size) args[index + 1] else default
}

val count = argValue(args, "--count", "100").toInt()
val outPath = argValue(args, "--out", "trades.json")
val books = listOf("EMEA_FI", "US_EQ", "APAC_FX")
val products = listOf("IRS", "FXFWD", "BOND", "EQUITY_SWAP")

val payload = buildString {
    append("[\n")
    repeat(count) { i ->
        val notional = Random.nextLong(50_000, 5_000_000)
        append("  {\"tradeId\": \"TRD-${i + 1}\", \"book\": \"${books.random()}\", \"product\": \"${products.random()}\", \"notional\": $notional}")
        append(if (i == count - 1) "\n" else ",\n")
    }
    append("]\n")
}

File(outPath).writeText(payload)
println("Generated $count trades at $outPath")
