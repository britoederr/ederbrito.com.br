import { About, Blog, Gallery, Home, Newsletter, Person, Social, Work } from "@/types";

const person: Person = {
  firstName: "Éder",
  lastName: "Brito",
  name: `Éder Brito`,
  role: "Lead Site Reliability Engineer",
  avatar: "/images/avatar.jpg",
  email: "britoederr@gmail.com",
  phone: "5561995742720",
  location: "America/Sao_Paulo",
  languages: ["English", "Portuguese"],
};

const newsletter: Newsletter = {
  display: false,
  title: <>Subscribe to {person.firstName}'s Newsletter</>,
  description: <>My weekly newsletter about reliability and engineering</>,
};

const social: Social = [
  {
    name: "GitHub",
    icon: "github",
    link: "https://github.com/britoederr",
    essential: true,
  },
  {
    name: "LinkedIn",
    icon: "linkedin",
    link: "https://www.linkedin.com/in/ederbrito/",
    essential: true,
  },
  {
    name: "Email",
    icon: "email",
    link: `mailto:${person.email}`,
    essential: true,
  },
  {
    name: "WhatsApp",
    icon: "whatsapp",
    link: `https://wa.me/${person.phone}`,
    essential: true,
  },
];

const home: Home = {
  path: "/",
  image: "/images/og/home.jpg",
  label: "Home",
  title: `${person.name}'s Portfolio`,
  description: `Portfolio website showcasing my work as a ${person.role}`,
  headline: <>Building reliable systems at cloud scale</>,
  featured: {
    display: false,
    title: <></>,
    href: "/work",
  },
  subline: (
    <>
      I'm {person.name}, a {person.role} with 10+ years of experience designing,
      securing, and operating highly available cloud-native platforms across AWS, GCP, and OCI.
    </>
  ),
};

const about: About = {
  path: "/about",
  label: "About",
  title: `About – ${person.name}`,
  description: `Meet ${person.name}, ${person.role} from ${person.location}`,
  tableOfContent: {
    display: false,
    subItems: false,
  },
  avatar: {
    display: true,
  },
  calendar: {
    display: false,
    link: "https://cal.com",
  },
  intro: {
    display: true,
    title: "Introduction",
    description: (
      <>
        Expert Site Reliability Engineer and DevOps Leader with 10+ years of experience in IT,
        designing, securing, and operating highly available, cloud-native platforms at a global
        scale. Proven track record of leading SRE initiatives, defining reliability standards, and
        acting as a technical role model across distributed teams. Deep expertise in Kubernetes,
        service mesh technologies, cloud security, observability, and automation in multi-cloud
        environments (AWS, GCP, Azure, OCI). Strong stakeholder manager with a proactive approach
        to incident prevention, system resilience, and continuous improvement.
      </>
    ),
  },
  work: {
    display: true,
    title: "Work Experience",
    experiences: [
      {
        company: "Avalara",
        timeframe: "2025 – Present",
        role: "Lead Site Reliability Engineer",
        achievements: [
          <>
            Act as technical lead and role model for SRE best practices across a global, multi-cloud
            environment (AWS, GCP, OCI).
          </>,
          <>
            Own SRE roadmap execution, aligning reliability, security, and scalability initiatives
            with business and engineering stakeholders.
          </>,
          <>
            Led architectural decisions for Kubernetes-based platforms, defining standards for
            deployment, observability, and availability.
          </>,
          <>
            Designed and implemented automated disaster recovery and ransomware resilience solutions
            using Terraform, Go, and Python.
          </>,
          <>
            Drove adoption of proactive incident management, improving detection, response times, and
            overall system reliability.
          </>,
          <>
            Mentored senior and mid-level engineers, fostering a strong SRE culture focused on
            ownership, collaboration, and continuous learning.
          </>,
        ],
        images: [],
      },
      {
        company: "Avalara",
        timeframe: "2021 – 2025",
        role: "Senior Site Reliability Engineer",
        achievements: [
          <>
            Led mission-critical ransomware recovery initiative, designing fully automated failover
            infrastructure from the ground up.
          </>,
          <>
            Standardized CI/CD pipelines across hundreds of repositories, significantly improving
            deployment consistency and developer experience.
          </>,
          <>
            Built and operated Kubernetes-based observability platforms (Prometheus, Grafana, Loki),
            enabling proactive monitoring and performance optimization.
          </>,
          <>
            Automated infrastructure provisioning, DNS, and backup workflows using Terraform and
            custom Go/Python tooling.
          </>,
          <>
            Facilitated incident war rooms and post-incident reviews, reducing MTTR and improving
            cross-team collaboration.
          </>,
        ],
        images: [],
      },
      {
        company: "Avalara",
        timeframe: "2021",
        role: "Site Reliability Engineer",
        achievements: [
          <>
            Enabled Infrastructure as Code adoption by importing and standardizing AWS resources
            with Terraform.
          </>,
          <>
            Improved incident response processes and operational readiness through structured on-call
            and escalation practices.
          </>,
        ],
        images: [],
      },
      {
        company: "Company Hero",
        timeframe: "2021",
        role: "DevOps Engineer",
        achievements: [
          <>
            Designed and implemented CI/CD pipelines using GitHub Actions to improve deployment
            speed and reliability.
          </>,
          <>
            Integrated monitoring and alerting solutions to enhance system stability and operational
            visibility.
          </>,
        ],
        images: [],
      },
      {
        company: "CAU/BR",
        timeframe: "2014 – 2021",
        role: "Infrastructure Analyst",
        achievements: [
          <>
            Worked building OpenSource solutions for the Brazilian public sector.
          </>,
          <>
            Implemented observability platforms and ITIL-aligned service catalogs to professionalize
            IT operations.
          </>,
        ],
        images: [],
      },
    ],
  },
  studies: {
    display: true,
    title: "Education & Certifications",
    institutions: [
      {
        name: "Faculdade Metropolitana – Brazil",
        description: <>MBA in Software Engineering (2021).</>,
      },
      {
        name: "Universidade do Distrito Federal – Brazil",
        description: <>Bachelor's in IT Management (2020).</>,
      },
      {
        name: "Certifications",
        description: (
          <>
            AWS Certified Solutions Architect – Associate · AWS Certified Developer – Associate ·
            AWS Cloud Practitioner · KCNA: Kubernetes and Cloud Native Associate · ITIL® v4
            Foundation · COBIT 2019 Foundation
          </>
        ),
      },
    ],
  },
  technical: {
    display: true,
    title: "Technical Skills",
    skills: [
      {
        title: "Cloud & Orchestration",
        description: (
          <>
            Multi-cloud architecture and operations across AWS, GCP, and OCI. Container
            orchestration with Kubernetes, Docker, and Helm; eBPF networking with Cilium and Hubble.
          </>
        ),
        tags: [
          { name: "AWS", icon: "aws" },
          { name: "GCP", icon: "gcp" },
          { name: "Kubernetes", icon: "kubernetes" },
          { name: "Docker", icon: "docker" },
          { name: "Helm", icon: "helm" },
          { name: "Cilium", icon: "kubernetes" },
        ],
        images: [],
      },
      {
        title: "IaC & Automation",
        description: (
          <>
            Infrastructure as Code with Terraform and Pulumi. Custom automation and tooling built
            with Python, Go, and Bash.
          </>
        ),
        tags: [
          { name: "Terraform", icon: "terraform" },
          { name: "Pulumi", icon: "pulumi" },
          { name: "Python", icon: "python" },
          { name: "Go", icon: "go" },
        ],
        images: [],
      },
      {
        title: "Observability & Reliability",
        description: (
          <>
            Full observability stack: metrics with Prometheus and Grafana, logs with Loki and
            FluentBit, traces with OTEL Collectors, Tempo, and Jaeger. Deep experience in incident
            response, disaster recovery, and resilience engineering.
          </>
        ),
        tags: [
          { name: "Prometheus", icon: "prometheus" },
          { name: "Grafana", icon: "grafana" },
        ],
        images: [],
      },
      {
        title: "CI/CD & Security",
        description: (
          <>
            Pipelines with GitLab CI, GitHub Actions, and Jenkins across hundreds of repositories.
            Cloud security via IAM, RBAC, and secrets management with HashiCorp Vault. ITIL v4
            and COBIT 2019 certified.
          </>
        ),
        tags: [
          { name: "GitLab CI", icon: "gitlab" },
          { name: "GitHub Actions", icon: "githubactions" },
          { name: "Jenkins", icon: "jenkins" },
          { name: "Vault", icon: "vault" },
        ],
        images: [],
      },
      {
        title: "Programming Languages",
        description: (
          <>
            <p>
              Python is my primary language, with prior experience as a Python developer building
              applications, automation, and integrations. I have developed APIs, data processing
              workflows, and internal tools, and continue to use Python extensively for cloud
              automation, observability, and reliability engineering tasks.
            </p>
            <p>
              I also have solid experience with Go, where I built performant services and developed
              custom Kubernetes operators to extend and automate cluster behavior. This includes
              working with controller patterns, reconciliation loops, and cloud-native design principles.
            </p>
            <p>
              Additionally, I write advanced Bash and PowerShell scripts for automation and CI/CD
              workflows, and work extensively with Infrastructure as Code using Terraform. My
              programming work is focused on improving system reliability, scalability, and developer
              experience across AWS, GCP, and Azure environments.
            </p>
          </>
        ),
        tags: [
          { name: "Python", icon: "python" },
          { name: "Go", icon: "go" },
          { name: "Bash", icon: "bash" },
          { name: "PowerShell", icon: "powershell" },
          { name: "Terraform", icon: "terraform" },
        ],
        images: [],
      },
    ],
  },
};

const blog: Blog = {
  path: "/blog",
  label: "Blog",
  title: "Writing about reliability, DevOps, and engineering...",
  description: `Read what ${person.name} has been up to recently`,
  // Create new blog posts by adding a new .mdx file to app/blog/posts
  // All posts will be listed on the /blog route
};

const work: Work = {
  path: "/work",
  label: "Work",
  title: `Projects – ${person.name}`,
  description: `SRE and infrastructure projects by ${person.name}`,
  // Create new project pages by adding a new .mdx file to app/work/projects
  // All projects will be listed on the /home and /work routes
};

const gallery: Gallery = {
  path: "/gallery",
  label: "Gallery",
  title: `Photo gallery – ${person.name}`,
  description: `A photo collection by ${person.name}`,
  images: [
    {
      src: "/images/gallery/horizontal-1.jpg",
      alt: "image",
      orientation: "horizontal",
    },
    {
      src: "/images/gallery/vertical-4.jpg",
      alt: "image",
      orientation: "vertical",
    },
    {
      src: "/images/gallery/horizontal-3.jpg",
      alt: "image",
      orientation: "horizontal",
    },
    {
      src: "/images/gallery/vertical-1.jpg",
      alt: "image",
      orientation: "vertical",
    },
    {
      src: "/images/gallery/vertical-2.jpg",
      alt: "image",
      orientation: "vertical",
    },
    {
      src: "/images/gallery/horizontal-2.jpg",
      alt: "image",
      orientation: "horizontal",
    },
    {
      src: "/images/gallery/horizontal-4.jpg",
      alt: "image",
      orientation: "horizontal",
    },
    {
      src: "/images/gallery/vertical-3.jpg",
      alt: "image",
      orientation: "vertical",
    },
  ],
};

export { person, social, newsletter, home, about, blog, work, gallery };
