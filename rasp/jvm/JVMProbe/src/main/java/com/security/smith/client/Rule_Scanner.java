package com.security.smith.client;

import java.util.Arrays;
import java.util.Base64;
import com.security.smith.client.message.*;
import com.security.smith.log.SmithLogger;

public class Rule_Scanner {
    public int m_version;
    public String m_virusName;
    public long m_flags;

    public long m_ruleId;

    public String m_className;

    public String m_classPath;

    public String m_interfaceName;

    public String m_classLoaderName;

    public String m_parentClassName;

    public byte[] m_virusSignature;

    public Rule_Scanner() {
    }

    public Rule_Scanner(Rule_Item RuleItem) {
        this.m_virusName = RuleItem.getVirusName();
        this.m_flags = RuleItem.getFlags();
        this.m_ruleId = RuleItem.getRuleId();
        this.m_className = RuleItem.getClassName();
        this.m_classPath = RuleItem.getClassPath();
        this.m_interfaceName = RuleItem.getInterfacesName();
        this.m_classLoaderName = RuleItem.getClassLoaderName();
        this.m_parentClassName = RuleItem.getParentClassName();

        String xvirusSignature = RuleItem.getVirusSignature();
        if(!xvirusSignature.isEmpty()) {
            byte[]  signatureData = java.util.Base64.getDecoder().decode(xvirusSignature);

            this.m_virusSignature = Arrays.copyOf(signatureData,signatureData.length);
        }
    }

    public void setVersion(int version) {
        this.m_version = version;
    }

    public long matchRule(ClassFilter data) {
        long rule_id = -1;
        int weight = 0;


        if(m_version == 1) {
            String className = data.getClassName();
            if(!m_className.isEmpty()) {
                if(className != null && className.matches(m_className)){
                    weight += 1;
                }
            }
            else {
                weight += 1;
            }

            String classPath = data.getClassPath();
            if(!m_classPath.isEmpty()) {
                if(classPath != null && classPath.matches(m_classPath)) {
                    weight += 1;
                }
            }
            else {
                weight += 1;
            }
          

            String interfaceName = data.getInterfacesName();
            if(!m_interfaceName.isEmpty()) {
                if(interfaceName != null && !interfaceName.isEmpty() &&  m_interfaceName.contains(interfaceName)) {
                    weight += 1;
                }
            }
            else {
                weight += 1;
            }
           

            String classLoaderName = data.getClassLoaderName();
            if(!m_classLoaderName.isEmpty()) {
                if(classLoaderName != null && classLoaderName.matches(m_classLoaderName)) {
                    weight += 1;
                }
            }
            else {
                weight += 1;
            }
           
            String parentClassName = data.getParentClassName();
            if(!m_parentClassName.isEmpty()) {
                if(parentClassName != null && parentClassName.matches(m_parentClassName)) {
                    weight += 1;
                }
            }
            else {
                weight += 1;
            }
           
            if(weight == 5) {
                rule_id = m_ruleId;
            }
        }

        return rule_id;
    }
}
