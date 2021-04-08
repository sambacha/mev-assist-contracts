import sys

from yattag import Doc

from slither.slither import Slither
from slither.slithir.operations import Call, EventCall
from slither.core.declarations import Modifier

if len(sys.argv) != 2:
    print("python3 solidityci.py contract.sol [output]")
    sys.exit(-1)

target = sys.argv[1]


def getEventsOfFunction(function):
    events = []
    for node in function.all_slithir_operations():
        if type(node) == EventCall:
            args = [str(a) for a in node.read]
            event = {"name": node.name, "args": args}
            events.append(event)
    return events


def getModifiersOfFunction(function):
    modifiers = [
        {"name": i.name, "modifiers": i}
        for i in function.all_internal_calls()
        if type(i) == Modifier
    ]
    return modifiers


def getSummaryOfContract(contract):
    contractSummary = []
    for function in contract.functions:
        if function.contract_declarer == contract and (
            function.visibility == "external" or function.visibility == "public"
        ):
            functionEvents = getEventsOfFunction(function)
            functionModifiers = getModifiersOfFunction(function)
            contractSummary.append(
                {
                    "name": function.name,
                    "modifiers": functionModifiers,
                    "events": functionEvents,
                    "function": function,
                }
            )
    return contractSummary


def getSummaryOfFile(f):
    slither = Slither(f)
    summaries = []
    for contract in slither.contracts:
        events = getSummaryOfContract(contract)
        summaries.append({"name": contract.name, "functions": events})
    return summaries


summary = getSummaryOfFile(target)

doc, tag, text = Doc().tagtext()

with tag("html"):
    with tag("body", id="report"):
        for s in summary:
            if len(s["functions"]) > 0:
                with tag("details", klass="contract", name=s["name"]):
                    with tag("summary"):
                        text("Contract: " + s["name"])
                    functions = s["functions"]
                    with tag("ul"):
                        for f in functions:
                            with tag("details", klass="function", name=f["name"]):
                                with tag("summary"):
                                    text("Function: " + f["name"])
                                with tag("ul"):
                                    if f["function"].view:
                                        with tag(
                                            "li", klass="mutability", name="mutability"
                                        ):
                                            text("view function")
                                    if len(f["modifiers"]) > 0:
                                        with tag(
                                            "details",
                                            klass="modifiers",
                                            name="modifiers",
                                        ):
                                            with tag("summary"):
                                                text("modifiers")
                                            with tag(
                                                "ul",
                                                klass="modifierlist",
                                                name="modifierlist",
                                            ):
                                                for m in f["modifiers"]:
                                                    with tag(
                                                        "li",
                                                        klass="modifier",
                                                        name=m["name"],
                                                    ):
                                                        text(m["name"])
                                    if len(f["events"]) > 0:
                                        with tag(
                                            "details", klass="events", name="events"
                                        ):
                                            with tag("summary"):
                                                text("events")
                                            with tag(
                                                "ul",
                                                klass="eventlist",
                                                name="eventlist",
                                            ):
                                                for e in f["events"]:
                                                    with tag(
                                                        "li",
                                                        klass="event",
                                                        name=e["name"],
                                                    ):
                                                        text(e["name"])

print(doc.getvalue())
