"use client";

import { usePathname } from "next/navigation";
import { useEffect, useRef, useState } from "react";

import { Button, Column, Fade, Flex, Icon, Line, Row, Tag, Text, ToggleButton } from "@once-ui-system/core";

import { routes, display, person, about, blog, work, gallery } from "@/resources";
import { ThemeToggle } from "./ThemeToggle";
import styles from "./Header.module.scss";

type TimeDisplayProps = {
  timeZone: string;
  locale?: string; // Optionally allow locale, defaulting to 'en-GB'
};

const TimeDisplay: React.FC<TimeDisplayProps> = ({ timeZone, locale = "en-GB" }) => {
  const [currentTime, setCurrentTime] = useState("");

  useEffect(() => {
    const updateTime = () => {
      const now = new Date();
      const options: Intl.DateTimeFormatOptions = {
        timeZone,
        hour: "2-digit",
        minute: "2-digit",
        second: "2-digit",
        hour12: false,
      };
      const timeString = new Intl.DateTimeFormat(locale, options).format(now);
      setCurrentTime(timeString);
    };

    updateTime();
    const intervalId = setInterval(updateTime, 1000);

    return () => clearInterval(intervalId);
  }, [timeZone, locale]);

  return <>{currentTime}</>;
};

export default TimeDisplay;

const microservices = [
  {
    name: "country-snapshot-api",
    description: "Country snapshot API",
    tech: "Go",
    techIcon: "go",
    href: "#",
  },
  {
    name: "web-performance-test-api",
    description: "Web performance test API",
    tech: "Python",
    techIcon: "python",
    href: "#",
  },
  {
    name: "ops-hub",
    description: "Operational dashboard",
    tech: "Next.js",
    techIcon: "nextjs",
    href: "#",
  },
];

const MicroservicesDropdown = ({ showLabel = true }: { showLabel?: boolean }) => {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) {
        setOpen(false);
      }
    };
    if (open) document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [open]);

  return (
    <div ref={ref} style={{ position: "relative" }}>
      <ToggleButton
        prefixIcon="globe"
        label={showLabel ? "Microservices" : undefined}
        selected={open}
        onClick={() => setOpen((o) => !o)}
      />
      {open && (
        <Column
          position="absolute"
          background="page"
          border="neutral-alpha-weak"
          radius="m"
          shadow="l"
          padding="8"
          gap="2"
          className={styles.dropdown}
          style={{
            left: "50%",
            transform: "translateX(-50%)",
            zIndex: 100,
            minWidth: "220px",
            whiteSpace: "nowrap",
          }}
        >
          {microservices.map(({ name, description, tech, techIcon, href }) => (
            <Row
              key={name}
              padding="8"
              gap="12"
              radius="s"
              vertical="center"
              style={{
                cursor: "not-allowed",
                opacity: 0.6,
                userSelect: "none",
              }}
            >
              <Icon name={techIcon} size="s" onBackground="neutral-weak" />
              <Column gap="2" flex={1}>
                <Row gap="8" vertical="center">
                  <Text variant="label-default-s">{name}</Text>
                  <Tag size="s">{tech}</Tag>
                </Row>
                <Text variant="body-default-xs" onBackground="neutral-weak">
                  {description}
                </Text>
              </Column>
              <Tag size="s">Soon</Tag>
            </Row>
          ))}
        </Column>
      )}
    </div>
  );
};

const playAreaLinks = [
  { label: "Prometheus", href: "https://prometheus.ederbrito.com.br", icon: "prometheus" },
  { label: "Grafana", href: "https://grafana.ederbrito.com.br", icon: "grafana" },
  { label: "Jaeger", href: "https://jaeger.ederbrito.com.br", icon: "rocket" },
  { label: "Loki", href: "https://loki.ederbrito.com.br", icon: "globe" },
  { label: "Hubble", href: "https://hubble.ederbrito.com.br", icon: "openLink" },
];

const PlayAreaDropdown = ({ showLabel = true }: { showLabel?: boolean }) => {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) {
        setOpen(false);
      }
    };
    if (open) document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [open]);

  return (
    <div ref={ref} style={{ position: "relative" }}>
      <ToggleButton
        prefixIcon="rocket"
        label={showLabel ? "Play Area" : undefined}
        selected={open}
        onClick={() => setOpen((o) => !o)}
      />
      {open && (
        <Column
          position="absolute"
          background="page"
          border="neutral-alpha-weak"
          radius="m"
          shadow="l"
          padding="8"
          gap="2"
          className={styles.dropdown}
          style={{
            left: "50%",
            transform: "translateX(-50%)",
            zIndex: 100,
            minWidth: "200px",
            whiteSpace: "nowrap",
          }}
        >
          {playAreaLinks.map(({ label, href, icon }) => (
            <Button
              key={label}
              href={href}
              label={label}
              prefixIcon={icon}
              variant="tertiary"
              size="s"
              weight="default"
            />
          ))}
        </Column>
      )}
    </div>
  );
};

export const Header = () => {
  const pathname = usePathname() ?? "";

  return (
    <>
      <Fade s={{ hide: true }} fillWidth position="fixed" height="80" zIndex={9} />
      <Fade
        hide
        s={{ hide: false }}
        fillWidth
        position="fixed"
        bottom="0"
        to="top"
        height="80"
        zIndex={9}
      />
      <Row
        fitHeight
        className={styles.position}
        position="sticky"
        as="header"
        zIndex={9}
        fillWidth
        padding="8"
        horizontal="center"
        data-border="rounded"
        s={{
          position: "fixed",
        }}
      >
        <Row paddingLeft="12" fillWidth vertical="center" textVariant="body-default-s">
          {display.location && <Row s={{ hide: true }}>{person.location}</Row>}
        </Row>
        <Row fillWidth horizontal="center">
          <Row
            background="page"
            border="neutral-alpha-weak"
            radius="m-4"
            shadow="l"
            padding="4"
            horizontal="center"
            zIndex={1}
          >
            <Row gap="4" vertical="center" textVariant="body-default-s" suppressHydrationWarning>
              {routes["/"] && (
                <ToggleButton prefixIcon="home" href="/" selected={pathname === "/"} />
              )}
              <Line background="neutral-alpha-medium" vert maxHeight="24" />
              {routes["/about"] && (
                <>
                  <Row s={{ hide: true }}>
                    <ToggleButton
                      prefixIcon="person"
                      href="/about"
                      label={about.label}
                      selected={pathname === "/about"}
                    />
                  </Row>
                  <Row hide s={{ hide: false }}>
                    <ToggleButton
                      prefixIcon="person"
                      href="/about"
                      selected={pathname === "/about"}
                    />
                  </Row>
                </>
              )}
              {routes["/work"] && (
                <>
                  <Row s={{ hide: true }}>
                    <ToggleButton
                      prefixIcon="grid"
                      href="/work"
                      label={work.label}
                      selected={pathname.startsWith("/work")}
                    />
                  </Row>
                  <Row hide s={{ hide: false }}>
                    <ToggleButton
                      prefixIcon="grid"
                      href="/work"
                      selected={pathname.startsWith("/work")}
                    />
                  </Row>
                </>
              )}
              {routes["/blog"] && (
                <>
                  <Row s={{ hide: true }}>
                    <ToggleButton
                      prefixIcon="book"
                      href="/blog"
                      label={blog.label}
                      selected={pathname.startsWith("/blog")}
                    />
                  </Row>
                  <Row hide s={{ hide: false }}>
                    <ToggleButton
                      prefixIcon="book"
                      href="/blog"
                      selected={pathname.startsWith("/blog")}
                    />
                  </Row>
                </>
              )}
              {routes["/gallery"] && (
                <>
                  <Row s={{ hide: true }}>
                    <ToggleButton
                      prefixIcon="gallery"
                      href="/gallery"
                      label={gallery.label}
                      selected={pathname.startsWith("/gallery")}
                    />
                  </Row>
                  <Row hide s={{ hide: false }}>
                    <ToggleButton
                      prefixIcon="gallery"
                      href="/gallery"
                      selected={pathname.startsWith("/gallery")}
                    />
                  </Row>
                </>
              )}
              <Line background="neutral-alpha-medium" vert maxHeight="24" />
              <Row s={{ hide: true }}>
                <MicroservicesDropdown />
              </Row>
              <Row hide s={{ hide: false }}>
                <MicroservicesDropdown showLabel={false} />
              </Row>
              <Row s={{ hide: true }}>
                <PlayAreaDropdown />
              </Row>
              <Row hide s={{ hide: false }}>
                <PlayAreaDropdown showLabel={false} />
              </Row>
              {display.themeSwitcher && (
                <>
                  <Line background="neutral-alpha-medium" vert maxHeight="24" />
                  <ThemeToggle />
                </>
              )}
            </Row>
          </Row>
        </Row>
        <Flex fillWidth horizontal="end" vertical="center">
          <Flex
            paddingRight="12"
            horizontal="end"
            vertical="center"
            textVariant="body-default-s"
            gap="20"
          >
            <Flex s={{ hide: true }}>
              {display.time && <TimeDisplay timeZone={person.location} />}
            </Flex>
          </Flex>
        </Flex>
      </Row>
    </>
  );
};
