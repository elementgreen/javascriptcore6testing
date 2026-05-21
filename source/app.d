import gobject.types;
import javascriptcore.context;
import javascriptcore.exception;
import javascriptcore.global;
import javascriptcore.types;
import javascriptcore.value;
import std.stdio;
import std.conv : to;

void main() {
	// Auto creates a VM.
	Context context = new Context();

	Value eval(string jsCode) {
		Value output = context.evaluate(jsCode);

		// This is how you check for errors.
		ExceptionWrap except = context.getException();
		if (except !is null) {
			writeln(except.toString_);
		}
		return output;
	}

  auto test = Value.newFunction(context, "test", (double number) {
		writeln("I am a callback! also: ", number);
		return "hello from the callback!";
  });

	context.setValue("test", test);

	Value output = eval("test(1);");

	if (output.isString()) {
		writeln(output.get!string);
	}

	context.setValue("testBoolean", Value.newFunction(context, "testBoolean", (bool val) {
		writeln("testBoolean: ", val);
		return val;
	}));

	context.setValue("testDouble", Value.newFunction(context, "testDouble", (double val) {
		writeln("testDouble: ", val);
		return val;
	}));

	context.setValue("testString", Value.newFunction(context, "testString", (string val) {
		writeln("testString: ", val);
		return val;
	}));

	context.setValue("testArray", Value.newFunction(context, "testArray", (double[] val) {
		writeln("testArray: ", val);
		return val;
	}));

	context.setValue("testMap", Value.newFunction(context, "testMap", (double[string] val) {
		writeln("testMap: ", val);
		return val;
	}));

	context.setValue("testValue", Value.newFunction(context, "testValue", (Value val) {
		writeln("testValue: ", val.toJson(2));
		return val;
	}));

	output = eval("testBoolean(true);");
	assert(output.isBoolean);
	assert(output.get!bool);

	output = eval("testDouble(13.42);");
	assert(output.isNumber);
	assert(output.get!double == 13.42);

	output = eval(`testString("Hi there!");`);
	assert(output.isString);
	assert(output.get!string == "Hi there!");

	auto testDblArrayVal = [1.0, 2.0, 3.0, 4.0];
	output = eval("testArray(" ~ testDblArrayVal.to!string ~ ");");
	assert(output.isArray);
	assert(output.get!(double[]) == testDblArrayVal);

	auto testObjectVal = ["a": 1.0, "b": 2.0, "c": 3.0, "d": 4.0];
	output = eval(`testMap({"a": 1.0, "b": 2.0, "c": 3.0, "d": 4.0});`);
	assert(output.isObject);
	assert(output.get!(double[string]) == testObjectVal);

	auto testArray = [Value.from(context, 42.0), Value.from(context, "I am string"), Value.from(context, [3.0, 2.0, 1.0]),
		Value.newFromJson(context, `{"a": 1.0, "b": "String value", "c": true, "d": null}`)];
	auto testArrayVal = Value.newArrayFromGarray(context, testArray);
  output = eval("testValue(" ~ testArrayVal.toJson(2) ~ ");");

	assert(output.isArray);
	assert(output.objectGetProperty("length").get!double == 4);

	auto itemVal = output.objectGetPropertyAtIndex(0);
	assert(itemVal.isNumber);
	assert(itemVal.get!double == 42.0);

	itemVal = output.objectGetPropertyAtIndex(1);
	assert(itemVal.isString);
	assert(itemVal.get!string == "I am string");

	itemVal = output.objectGetPropertyAtIndex(2);
	assert(itemVal.isArray);
	assert(itemVal.get!(double[]) == [3.0, 2.0, 1.0]);

	itemVal = output.objectGetPropertyAtIndex(3);
	assert(itemVal.isObject);
	auto objVal = itemVal.objectGetProperty("a");
	assert(objVal.isNumber);
	assert(objVal.get!double == 1.0);
	objVal = itemVal.objectGetProperty("b");
	assert(objVal.isString);
	assert(objVal.get!string == "String value");
	objVal = itemVal.objectGetProperty("c");
	assert(objVal.isBoolean);
	assert(objVal.get!bool == true);
	objVal = itemVal.objectGetProperty("d");
	assert(objVal.isNull);

 	context.destroy();
}
