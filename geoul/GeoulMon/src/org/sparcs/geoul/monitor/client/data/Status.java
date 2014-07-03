package org.sparcs.geoul.monitor.client.data;

import java.io.Serializable;
import java.util.Date;

import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;

@SuppressWarnings("serial")
public class Status implements Serializable {

	public static class Event implements Serializable {
		@XmlAttribute
		private Date timestamp;
		@XmlAttribute
		private String href;

		public Date getTimestamp() {
			return timestamp;
		}

		public String getHref() {
			return href;
		}

		@Override
		public String toString() {
			return "on " + timestamp;
		}
	}

	public static class CountableEvent extends Event {
		@XmlAttribute
		private int count;

		public int getCount() {
			return count;
		}

		@Override
		public String toString() {
			return count + " times " + super.toString();
		}
	}

	@XmlElement
	private Event updated;
	@XmlElement
	private CountableEvent failed;
	@XmlElement
	private Event updating;

	public Event getUpdated() {
		return updated;
	}

	public CountableEvent getFailed() {
		return failed;
	}

	public Event getUpdating() {
		return updating;
	}

	// enum Freshness {
	// FRESH, OLD, BAD,
	// }
	// private Freshness freshness;
	// private boolean syncInProgress;

	@Override
	public String toString() {
		return "updated " + updated + "; failed " + failed + "; updating "
				+ updating;
	}
}
