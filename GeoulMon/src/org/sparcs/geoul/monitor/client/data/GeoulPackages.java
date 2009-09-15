package org.sparcs.geoul.monitor.client.data;

import java.io.Serializable;
import java.util.Collections;
import java.util.List;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

@SuppressWarnings("serial")
@XmlRootElement(name = "packages")
public class GeoulPackages implements Serializable {
	@XmlElement(name = "package")
	private List<GeoulPackage> geoulPackages;

	public List<GeoulPackage> getPackages() {
		return geoulPackages;
	}

	@Override
	public String toString() {
		if (geoulPackages != null)
			return geoulPackages.toString();
		else
			return Collections.emptyList().toString();
	}
}
