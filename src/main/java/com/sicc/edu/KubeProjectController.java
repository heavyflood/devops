package com.sicc.edu;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;


@RestController
public class KubeProjectController {

	@RequestMapping("/")
	public String SpringDockerTest() {
		return "{'"
				+ "====================================="
				+ "\n"
				+ "		Kubernetes !!		"
				+ "\n"
				+ "====================================="
				+ "'}";
	}
}
