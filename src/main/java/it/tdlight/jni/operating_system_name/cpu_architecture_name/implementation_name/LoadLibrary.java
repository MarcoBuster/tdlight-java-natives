package it.tdlight.jni.operating_system_name.cpu_architecture_name.implementation_name;

import java.lang.ClassLoader;

public class LoadLibrary {
	public static ClassLoader getClassLoader() {
		return LoadLibrary.class.getClassLoader();
	}
}
