package org.sparcs.geoul.monitor.client.data;

import java.io.Serializable;
import java.util.Collections;
import java.util.List;

import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;

@SuppressWarnings("serial")
public class GeoulPackage implements Serializable {

	@XmlAttribute
	private String id;

	@XmlAttribute
	private String name;

	public static class SyncConfig implements Serializable {
		@XmlAttribute
		private String source;
		@XmlAttribute
		private String frequency;

		public String getSource() {
			return source;
		}

		public String getFrequency() {
			return frequency;
		}

		@Override
		public String toString() {
			return "sync from " + source + " every " + frequency;
		}
	}

	@XmlElement
	private SyncConfig sync;

	public static class Link implements Serializable {
		@XmlAttribute
		private String rel;
		@XmlAttribute
		private String href;

		public String getRel() {
			return rel;
		}

		public String getHref() {
			return href;
		}

		@Override
		public String toString() {
			return "link rel=" + rel + " href=" + href;
		}
	}

	@XmlElement(name = "link")
	private List<Link> links;

	@XmlElement
	private Status status;

	public String getId() {
		return id;
	}

	public String getName() {
		return name;
	}

	public SyncConfig getSyncConfig() {
		return sync;
	}

	public List<Link> getLinks() {
		if (links != null)
			return links;
		else
			return Collections.emptyList();
	}

	public Status getStatus() {
		return status;
	}

	@Override
	public String toString() {
		return "GeoulPackage " + id + " (" + status + ")";
	}
}
